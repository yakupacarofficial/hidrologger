import json
import os
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime, timezone
import traceback
import time

logger = logging.getLogger(__name__)

class JSONReader:
    def __init__(self, base_path: str = "jsons"):
        # Eğer jsons klasörü mevcut değilse, python_server/jsons'u dene
        if not os.path.exists(base_path) and os.path.exists(os.path.join("python_server", base_path)):
            base_path = os.path.join("python_server", base_path)
        
        self.base_path = base_path
        self.constant_path = os.path.join(base_path, "constant")
        self.variable_path = os.path.join(base_path, "variable")
        self.semi_variable_path = os.path.join(base_path, "semi-variable")
        self.alarm_path = os.path.join(base_path, "alarm")
        self.logsfile_path = os.path.join(base_path, "logsfile")
        
        # Dosya izleme için
        self.file_last_modified = {}
        self.last_successful_data = None
        self.last_check_time = 0
        self.check_interval = 0.1  # Saniye cinsinden kontrol aralığı (100ms)
        
        # Başlangıçta tüm dosyaları tara
        self._initialize_file_tracking()
        
        logger.info("JSONReader başlatıldı")
    
    def _initialize_file_tracking(self):
        """Tüm JSON dosyalarının son değiştirilme zamanlarını kaydet"""
        for folder_path in [self.constant_path, self.variable_path, self.semi_variable_path, self.alarm_path, self.logsfile_path]:
            if os.path.exists(folder_path):
                for filename in os.listdir(folder_path):
                    if filename.endswith('.json'):
                        file_path = os.path.join(folder_path, filename)
                        try:
                            self.file_last_modified[file_path] = os.path.getmtime(file_path)
                        except OSError:
                            self.file_last_modified[file_path] = 0
    
    def _read_json_file(self, file_path: str) -> Optional[Dict[str, Any]]:
        """Tek bir JSON dosyasını güvenli şekilde oku"""
        try:
            if not os.path.exists(file_path):
                logger.warning(f"Dosya bulunamadı: {file_path}")
                return {}
                
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read().strip()
                if not content:
                    logger.warning(f"Dosya boş: {file_path}")
                    return {}
                    
                data = json.loads(content)
                logger.debug(f"Dosya başarıyla okundu: {file_path}")
                return data
                
        except json.JSONDecodeError as e:
            logger.error(f"JSON parse hatası {file_path}: {e}")
            return {}
        except Exception as e:
            logger.error(f"Dosya okuma hatası {file_path}: {e}")
            return {}
    
    def _read_directory_files(self, directory_path: str, category_name: str) -> Dict[str, Any]:
        """Bir klasördeki tüm JSON dosyalarını oku"""
        result = {}
        
        if not os.path.exists(directory_path):
            logger.warning(f"{category_name} klasörü bulunamadı: {directory_path}")
            return result
        
        try:
            files = [f for f in os.listdir(directory_path) if f.endswith('.json')]
            logger.debug(f"{category_name} klasöründe {len(files)} JSON dosyası bulundu")
            
            for filename in files:
                file_path = os.path.join(directory_path, filename)
                file_key = os.path.splitext(filename)[0]  # .json uzantısını kaldır
                
                data = self._read_json_file(file_path)
                # Boş dosyalar için boş dict döndürüyor, bu durumda da işleme devam et
                if data is not None and data != {}:
                    # Çift başlık problemini önlemek için:
                    # 1. Dosya içeriği tek bir anahtar içeriyorsa ve bu anahtar dosya adıyla aynıysa
                    # 2. Veya dosya adı kategori adıyla aynıysa (örn: alarm.json -> alarm kategorisi)
                    if (len(data) == 1 and file_key in data) or (file_key == category_name.lower()):
                        if len(data) == 1 and file_key in data:
                            result[file_key] = data[file_key]
                        else:
                            # Dosya adı kategori adıyla aynıysa, içeriği doğrudan kullan
                            result.update(data)
                    else:
                        result[file_key] = data
                    logger.info(f"{category_name} verisi yüklendi: {file_key}")
                elif data == {}:
                    # Boş dosya durumu - boş dict ekle
                    result[file_key] = {}
                    logger.info(f"{category_name} boş dosya işlendi: {file_key}")
                else:
                    logger.error(f"{category_name} verisi yüklenemedi: {file_key}")
                    
        except Exception as e:
            logger.error(f"{category_name} klasörü okuma hatası: {e}")
            
        return result
    
    def _has_files_changed(self) -> bool:
        """Dosyalarda değişiklik olup olmadığını kontrol et"""
        current_time = time.time()
        
        # Kontrol aralığını kontrol et - çok sıkı olmasın
        if current_time - self.last_check_time < self.check_interval:
            return False
            
        self.last_check_time = current_time
        
        # Her zaman değişiklik var kabul et (geliştirme için)
        # TODO: Production'da daha akıllı kontrol yapılacak
        logger.debug("Dosya değişikliği kontrolü yapılıyor...")
        
        for file_path, last_modified in self.file_last_modified.items():
            try:
                if os.path.exists(file_path):
                    current_modified = os.path.getmtime(file_path)
                    if current_modified != last_modified:
                        logger.info(f"Dosya değişikliği tespit edildi: {file_path}")
                        self.file_last_modified[file_path] = current_modified
                        return True
                else:
                    # Dosya silinmiş
                    logger.warning(f"Dosya silinmiş: {file_path}")
                    return True
            except OSError:
                continue
                
        # Yeni dosyalar var mı kontrol et
        for folder_path in [self.constant_path, self.variable_path, self.alarm_path]:
            if os.path.exists(folder_path):
                for filename in os.listdir(folder_path):
                    if filename.endswith('.json'):
                        file_path = os.path.join(folder_path, filename)
                        if file_path not in self.file_last_modified:
                            logger.info(f"Yeni dosya tespit edildi: {file_path}")
                            self.file_last_modified[file_path] = os.path.getmtime(file_path)
                            return True
        
        # Geliştirme için: Her zaman değişiklik var kabul et
        logger.debug("Geliştirme modu: Cache bypass ediliyor")
        return True
    
    def read_all_data(self) -> Optional[Dict[str, Any]]:
        """Tüm JSON verilerini oku ve birleştir - ALARM VERİLERİ EKLENDİ"""
        try:
            # Dosya değişikliği kontrolü
            if not self._has_files_changed() and self.last_successful_data is not None:
                logger.debug("Dosya değişikliği yok, önbellek kullanılıyor")
                return self.last_successful_data
            
            logger.info("JSON dosyaları okunuyor...")
            
            # Variable ve alarm verilerini oku
            variable_data = self._read_directory_files(self.variable_path, "Variable")
            alarm_data = self._read_directory_files(self.alarm_path, "Alarm")
            
            # Verileri birleştir
            combined_data = {
                "timestamp": datetime.now().isoformat(),
                "variable": variable_data,
                "alarm": alarm_data
            }
            
            # Veri boyutunu hesapla
            data_size = len(json.dumps(combined_data, ensure_ascii=False))
            logger.info(f"Birleştirilmiş veri boyutu: {data_size} byte")
            
            # Veri doğrulama
            if self._validate_data(combined_data):
                self.last_successful_data = combined_data
                logger.info("JSON verileri başarıyla okundu ve birleştirildi (alarm verileri dahil)")
                return combined_data
            else:
                logger.error("Veri doğrulama başarısız")
                # Önceki başarılı veriyi döndür
                if self.last_successful_data is not None:
                    logger.info("Önceki başarılı veri kullanılıyor")
                    return self.last_successful_data
                return None
                
        except Exception as e:
            logger.error(f"Veri okuma hatası: {e}")
            logger.error(traceback.format_exc())
            
            # Hata durumunda önceki başarılı veriyi döndür
            if self.last_successful_data is not None:
                logger.info("Hata nedeniyle önceki başarılı veri kullanılıyor")
                return self.last_successful_data
            return None
    
    def _validate_data(self, data: Dict[str, Any]) -> bool:
        """Veri bütünlüğünü kontrol et - ALARM VERİLERİ EKLENDİ"""
        try:
            # Temel yapı kontrolü
            required_keys = ["timestamp", "variable"]
            for key in required_keys:
                if key not in data:
                    logger.error(f"Eksik anahtar: {key}")
                    return False
            
            # Timestamp kontrolü
            if not data["timestamp"]:
                logger.error("Timestamp boş")
                return False
            
            # Boş dosyalar da geçerli durumlar, bu yüzden her zaman True döndür
            # Sadece timestamp'in var olması yeterli
            logger.debug("Veri doğrulama başarılı (boş dosyalar dahil)")
            return True
            
            logger.debug("Veri doğrulama başarılı")
            return True
            
        except Exception as e:
            logger.error(f"Veri doğrulama hatası: {e}")
            return False
    
    def get_data_summary(self) -> Dict[str, Any]:
        """Veri özetini döndür - ALARM VERİLERİ EKLENDİ"""
        if self.last_successful_data is None:
            return {"status": "no_data"}
        
        try:
            return {
                "timestamp": self.last_successful_data.get("timestamp"),
                "categories": {
                    "variable": len(self.last_successful_data.get("variable", {})),
                    "alarm": len(self.last_successful_data.get("alarm", {}))
                }
            }
        except Exception as e:
            logger.error(f"Özet oluşturma hatası: {e}")
            return {"status": "error", "error": str(e)}
    
    def force_reload(self):
        """Tüm verileri zorla yeniden yükle"""
        logger.info("Zorla yeniden yükleme başlatılıyor")
        self.last_successful_data = None
        self._initialize_file_tracking()
        return self.read_all_data()
    
    def get_specific_data(self, category: str, file_key: str) -> Optional[Dict[str, Any]]:
        """Belirli bir kategoriden belirli bir dosyanın verisini al"""
        if self.last_successful_data is None:
            logger.warning("Henüz veri yüklenmemiş")
            return None
        
        try:
            category_data = self.last_successful_data.get(category, {})
            return category_data.get(file_key)
        except Exception as e:
            logger.error(f"Belirli veri alma hatası: {e}")
            return None

    def create_channel(self, channel_data: Dict[str, Any]) -> bool:
        """Yeni kanal oluştur ve data.json'a otomatik veri bloğu ekle"""
        try:
            logger.info(f"Yeni kanal oluşturma: {channel_data}")
            
            # Gerekli alanları kontrol et
            required_fields = ['id', 'name', 'description']
            for field in required_fields:
                if field not in channel_data:
                    logger.error(f"Eksik alan: {field}")
                    return False
            
            # Channel dosyasının yolunu belirle
            channel_file_path = os.path.join(self.variable_path, "channel.json")
            data_file_path = os.path.join(self.variable_path, "data.json")
            logger.info(f"Channel dosya yolu: {channel_file_path}")
            logger.info(f"Data dosya yolu: {data_file_path}")
            
            # Dosyayı oku veya yeni oluştur
            if os.path.exists(channel_file_path):
                logger.info("Mevcut channel.json dosyası okunuyor")
                try:
                    with open(channel_file_path, 'r', encoding='utf-8') as file:
                        data = json.load(file)
                    logger.info(f"Mevcut kanal sayısı: {len(data.get('channel', []))}")
                except (json.JSONDecodeError, FileNotFoundError):
                    logger.warning("Channel.json dosyası bozuk, yeni dosya oluşturuluyor")
                    data = {"channel": []}
            else:
                logger.info("Yeni channel.json dosyası oluşturuluyor")
                data = {"channel": []}
            
            # Kanal ID'sinin benzersiz olduğunu kontrol et
            channels = data.get('channel', [])
            existing_ids = [ch.get('id') for ch in channels if ch.get('id') is not None]
            if channel_data.get('id') in existing_ids:
                logger.error(f"Kanal ID {channel_data.get('id')} zaten mevcut")
                return False
            
            # Yeni kanalı ekle
            channels.append(channel_data)
            data['channel'] = channels
            
            logger.info(f"Yeni kanal eklendi. Toplam kanal sayısı: {len(channels)}")
            
            # Channel dosyasını kaydet
            with open(channel_file_path, 'w', encoding='utf-8') as file:
                json.dump(data, file, indent=2, ensure_ascii=False)
            
            # Data.json dosyasına yeni veri bloğu ekle
            self._add_data_entry_for_channel(channel_data.get('id'))
            
            logger.info(f"Yeni kanal başarıyla oluşturuldu: ID={channel_data.get('id')}")
            return True
            
        except Exception as e:
            logger.error(f"Kanal oluşturma hatası: {e}")
            import traceback
            logger.error(f"Hata detayı: {traceback.format_exc()}")
            return False

    def delete_channel(self, channel_id: int) -> bool:
        """Kanalı sil ve ilgili data'yı da sil"""
        try:
            logger.info(f"Kanal silme: ID={channel_id}")
            
            # Channel dosyasının yolunu belirle
            channel_file_path = os.path.join(self.variable_path, "channel.json")
            data_file_path = os.path.join(self.variable_path, "data.json")
            
            if not os.path.exists(channel_file_path):
                logger.error(f"Channel dosyası bulunamadı: {channel_file_path}")
                return False
            
            # Channel dosyasını oku
            try:
                with open(channel_file_path, 'r', encoding='utf-8') as file:
                    channel_data = json.load(file)
            except (json.JSONDecodeError, FileNotFoundError):
                logger.error("Channel.json dosyası okunamadı")
                return False
            
            # Kanalı bul ve sil
            channels = channel_data.get('channel', [])
            
            # Silinecek kanalı bul
            channel_to_delete = None
            for ch in channels:
                if ch.get('id') == channel_id:
                    channel_to_delete = ch
                    break
            
            if channel_to_delete is None:
                logger.warning(f"Kanal bulunamadı: ID={channel_id}")
                return False
            
            # Kanalı listeden çıkar
            channels = [ch for ch in channels if ch.get('id') != channel_id]
            channel_data['channel'] = channels
            
            logger.info(f"Silinecek kanal: {channel_to_delete.get('name', 'Bilinmeyen')}")
            
            # Channel dosyasını kaydet
            with open(channel_file_path, 'w', encoding='utf-8') as file:
                json.dump(channel_data, file, indent=2, ensure_ascii=False)
            
            # Data dosyasından da ilgili veriyi sil
            if os.path.exists(data_file_path):
                try:
                    with open(data_file_path, 'r', encoding='utf-8') as file:
                        data_content = json.load(file)
                    
                    # Data listesini al
                    data_list = data_content.get('data', [])
                    
                    # Kanal ID'sine ait verileri filtrele
                    original_data_count = len(data_list)
                    data_list = [d for d in data_list if d.get('channel') != channel_id]
                    
                    data_content['data'] = data_list
                    
                    # Data dosyasını kaydet
                    with open(data_file_path, 'w', encoding='utf-8') as file:
                        json.dump(data_content, file, indent=2, ensure_ascii=False)
                    
                    deleted_data_count = original_data_count - len(data_list)
                    logger.info(f"Data dosyasından {deleted_data_count} veri silindi")
                    
                except (json.JSONDecodeError, FileNotFoundError) as e:
                    logger.warning(f"Data dosyası işlenirken hata: {e}")
            
            logger.info(f"Kanal ve ilgili veriler başarıyla silindi: ID={channel_id}")
            return True
            
        except Exception as e:
            logger.error(f"Kanal silme hatası: {e}")
            import traceback
            logger.error(f"Hata detayı: {traceback.format_exc()}")
            return False

    def update_channel_field(self, channel_id: int, field: str, value: Any) -> bool:
        """Kanal bilgilerini güncelle"""
        try:
            logger.info(f"Kanal güncelleme: ID={channel_id}, Field={field}, Value={value}")
            
            # Channel dosyasının yolunu belirle (artık variable klasöründe)
            channel_file_path = os.path.join(self.variable_path, "channel.json")
            
            if not os.path.exists(channel_file_path):
                logger.error(f"Channel dosyası bulunamadı: {channel_file_path}")
                return False
            
            # Dosyayı oku
            with open(channel_file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)
            
            # Kanalı bul
            channels = data.get('channel', [])
            channel_found = False
            
            for channel in channels:
                if channel.get('id') == channel_id:
                    channel_found = True
                    
                    # Alan adını JSON formatına çevir (snake_case)
                    json_field = field
                    if field == 'logInterval':
                        json_field = 'log_interval'
                    elif field == 'measurementUnit':
                        json_field = 'measurement_unit'
                    elif field == 'channelCategory':
                        json_field = 'channel_category'
                    elif field == 'channelSubCategory':
                        json_field = 'channel_sub_category'
                    elif field == 'channelParameter':
                        json_field = 'channel_parameter'
                    
                    # Değer tipini kontrol et ve dönüştür
                    if json_field in ['id', 'channel_category', 'channel_sub_category', 'channel_parameter', 'measurement_unit', 'log_interval']:
                        try:
                            value = int(value)
                        except (ValueError, TypeError):
                            logger.error(f"Geçersiz sayısal değer: {value}")
                            return False
                    elif json_field == 'offset':
                        try:
                            value = float(value)
                        except (ValueError, TypeError):
                            logger.error(f"Geçersiz ondalıklı değer: {value}")
                            return False
                    
                    # Değeri güncelle
                    old_value = channel.get(json_field)
                    channel[json_field] = value
                    logger.info(f"Kanal {channel_id} güncellendi: {json_field} = {old_value} -> {value}")
                    break
            
            if not channel_found:
                logger.error(f"Kanal bulunamadı: ID={channel_id}")
                return False
            
            # Dosyayı geri yaz
            with open(channel_file_path, 'w', encoding='utf-8') as file:
                json.dump(data, file, indent=2, ensure_ascii=False)
            
            # Dosya değişiklik zamanını güncelle
            self.file_last_modified[channel_file_path] = os.path.getmtime(channel_file_path)
            
            # Cache'i temizle
            self.last_successful_data = None
            
            logger.info(f"Kanal {channel_id} başarıyla güncellendi")
            return True
            
        except Exception as e:
            logger.error(f"Kanal güncelleme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def save_alarm_data(self, alarm_data: Dict[str, Any]) -> bool:
        """Alarm verilerini kaydet"""
        try:
            logger.info("Alarm verileri kaydediliyor...")
            
            alarm_file_path = os.path.join(self.alarm_path, "alarm.json")
            
            # Dosyayı yaz
            with open(alarm_file_path, 'w', encoding='utf-8') as file:
                json.dump(alarm_data, file, indent=2, ensure_ascii=False)
            
            # Dosya değişiklik zamanını güncelle
            self.file_last_modified[alarm_file_path] = os.path.getmtime(alarm_file_path)
            
            # Cache'i temizle
            self.last_successful_data = None
            
            logger.info("Alarm verileri başarıyla kaydedildi")
            return True
            
        except Exception as e:
            logger.error(f"Alarm verileri kaydetme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def get_alarm_data(self) -> Optional[Dict[str, Any]]:
        """Alarm verilerini oku"""
        try:
            alarm_file_path = os.path.join(self.alarm_path, "alarm.json")
            return self._read_json_file(alarm_file_path)
        except Exception as e:
            logger.error(f"Alarm verileri okuma hatası: {e}")
            return None

    def _add_data_entry_for_channel(self, channel_id: int) -> bool:
        """Yeni kanal için data.json dosyasına veri bloğu ekle"""
        try:
            logger.info(f"Kanal {channel_id} için data.json'a veri bloğu ekleniyor")
            
            data_file_path = os.path.join(self.variable_path, "data.json")
            
            # Mevcut data.json dosyasını oku
            if os.path.exists(data_file_path):
                try:
                    with open(data_file_path, 'r', encoding='utf-8') as file:
                        data_content = json.load(file)
                except (json.JSONDecodeError, FileNotFoundError):
                    logger.warning("Data.json dosyası bozuk, yeni dosya oluşturuluyor")
                    data_content = {"data": []}
            else:
                logger.info("Yeni data.json dosyası oluşturuluyor")
                data_content = {"data": []}
            
            # Mevcut veri listesini al
            data_list = data_content.get('data', [])
            
            # Yeni veri bloğu için benzersiz ID bul
            existing_ids = [item.get('id') for item in data_list if item.get('id') is not None]
            new_data_id = max(existing_ids) + 1 if existing_ids else 1
            
            # Şu anki timestamp'i al
            current_timestamp = int(time.time())
            
            # Yeni veri bloğu oluştur
            new_data_entry = {
                "id": new_data_id,
                "channel": channel_id,
                "value_type": 1,  # Varsayılan değer tipi
                "value_timestamp": current_timestamp,
                "value": 0,  # Varsayılan değer
                "min_value": 0,  # Varsayılan min değer
                "max_value": 0,  # Varsayılan max değer
                "battery_percentage": 100,  # Varsayılan batarya
                "signal_strength": 100  # Varsayılan sinyal gücü
            }
            
            # Yeni veri bloğunu listeye ekle
            data_list.append(new_data_entry)
            data_content['data'] = data_list
            
            # Dosyayı kaydet
            with open(data_file_path, 'w', encoding='utf-8') as file:
                json.dump(data_content, file, indent=2, ensure_ascii=False)
            
            # Dosya değişiklik zamanını güncelle
            self.file_last_modified[data_file_path] = os.path.getmtime(data_file_path)
            
            # Cache'i temizle
            self.last_successful_data = None
            
            logger.info(f"Kanal {channel_id} için veri bloğu başarıyla eklendi: ID={new_data_id}")
            return True
            
        except Exception as e:
            logger.error(f"Data bloğu ekleme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def save_log_data(self, channel_id: int, value: float, timestamp: Optional[str] = None) -> bool:
        """Log verilerini kaydet"""
        try:
            logger.info(f"Kanal {channel_id} için log verisi kaydediliyor...")
            
            logs_file_path = os.path.join(self.logsfile_path, "logs.json")
            
            # Mevcut logs.json dosyasını oku
            if os.path.exists(logs_file_path):
                try:
                    with open(logs_file_path, 'r', encoding='utf-8') as file:
                        logs_content = json.load(file)
                except (json.JSONDecodeError, FileNotFoundError):
                    logger.warning("Logs.json dosyası bozuk, yeni dosya oluşturuluyor")
                    logs_content = {"logs": {}}
            else:
                logger.info("Yeni logs.json dosyası oluşturuluyor")
                logs_content = {"logs": {}}
            
            # Timestamp'i belirle
            if timestamp is None:
                timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
            
            # Kanal için log verilerini al
            logs = logs_content.get('logs', {})
            channel_key = f"channel_{channel_id}"
            
            if channel_key not in logs:
                logs[channel_key] = {
                    "channel_id": channel_id,
                    "channel_name": self._get_channel_name(channel_id),
                    "data": []
                }
            
            # Yeni log kaydı için ID bul
            existing_logs = logs[channel_key].get('data', [])
            existing_ids = [log.get('id') for log in existing_logs if log.get('id') is not None]
            new_log_id = max(existing_ids) + 1 if existing_ids else 1
            
            # Data.json'dan min/max değerleri al
            min_value = 0
            max_value = 0
            data_file_path = os.path.join(self.variable_path, "data.json")
            if os.path.exists(data_file_path):
                try:
                    data_content = self._read_json_file(data_file_path)
                    if data_content and 'data' in data_content:
                        for data_entry in data_content['data']:
                            if data_entry.get('channel') == channel_id:
                                min_value = data_entry.get('min_value', 0)
                                max_value = data_entry.get('max_value', 0)
                                break
                except Exception as e:
                    logger.warning(f"Data.json'dan min/max değerleri alınamadı: {e}")
            
            # Yeni log kaydı oluştur
            new_log_entry = {
                "id": new_log_id,
                "timestamp": timestamp,
                "value": value,
                "min_value": min_value,
                "max_value": max_value
            }
            
            # Log kaydını listeye ekle
            logs[channel_key]['data'].append(new_log_entry)
            logs_content['logs'] = logs
            
            # Dosyayı kaydet
            with open(logs_file_path, 'w', encoding='utf-8') as file:
                json.dump(logs_content, file, indent=2, ensure_ascii=False)
            
            # Dosya değişiklik zamanını güncelle
            self.file_last_modified[logs_file_path] = os.path.getmtime(logs_file_path)
            
            logger.info(f"Kanal {channel_id} için log verisi başarıyla kaydedildi: ID={new_log_id}")
            return True
            
        except Exception as e:
            logger.error(f"Log verisi kaydetme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def get_log_data(self, channel_id: int, start_date: Optional[str] = None, end_date: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Belirli kanal için log verilerini getir"""
        try:
            logs_file_path = os.path.join(self.logsfile_path, "logs.json")
            
            if not os.path.exists(logs_file_path):
                logger.warning("Logs.json dosyası bulunamadı")
                return None
            
            logs_content = self._read_json_file(logs_file_path)
            if not logs_content:
                return None
            
            logs = logs_content.get('logs', {})
            channel_key = f"channel_{channel_id}"
            
            if channel_key not in logs:
                logger.info(f"Kanal {channel_id} için log verisi bulunamadı")
                return None
            
            channel_logs = logs[channel_key].copy()
            
            # Tarih filtreleme
            if start_date or end_date:
                logger.info(f"Tarih filtreleme başlıyor - Başlangıç: {start_date}, Bitiş: {end_date}")
                logger.info(f"Filtreleme öncesi log sayısı: {len(channel_logs.get('data', []))}")
                
                filtered_data = []
                for log_entry in channel_logs.get('data', []):
                    log_timestamp = log_entry.get('timestamp', '')
                    logger.info(f"Log entry timestamp: {log_timestamp}")
                    
                    try:
                        # Timestamp'i datetime objesine çevir
                        if log_timestamp:
                            log_dt = datetime.fromisoformat(log_timestamp.replace('Z', '+00:00'))
                            logger.info(f"Parse edilen log_dt: {log_dt}")
                            
                            # Başlangıç tarihi kontrolü
                            if start_date:
                                start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
                                # Eğer start_dt offset-naive ise, UTC olarak kabul et
                                if start_dt.tzinfo is None:
                                    start_dt = start_dt.replace(tzinfo=timezone.utc)
                                logger.info(f"Başlangıç tarihi: {start_dt}")
                                if log_dt < start_dt:
                                    logger.info(f"Log tarihi {log_dt} başlangıç tarihinden {start_dt} küçük, atlanıyor")
                                    continue
                            
                            # Bitiş tarihi kontrolü
                            if end_date:
                                end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
                                # Eğer end_dt offset-naive ise, UTC olarak kabul et
                                if end_dt.tzinfo is None:
                                    end_dt = end_dt.replace(tzinfo=timezone.utc)
                                logger.info(f"Bitiş tarihi: {end_dt}")
                                if log_dt > end_dt:
                                    logger.info(f"Log tarihi {log_dt} bitiş tarihinden {end_dt} büyük, atlanıyor")
                                    continue
                            
                            # Tüm kontrolleri geçti, veriyi ekle
                            logger.info(f"Log entry filtrelendi ve eklendi: {log_entry}")
                            filtered_data.append(log_entry)
                        else:
                            # Timestamp yoksa veriyi ekle
                            logger.info(f"Timestamp yok, log entry eklendi: {log_entry}")
                            filtered_data.append(log_entry)
                        
                    except Exception as e:
                        logger.warning(f"Timestamp parse hatası: {log_timestamp} - {e}")
                        # Parse edilemeyen timestamp'leri de dahil et
                        filtered_data.append(log_entry)
                
                channel_logs['data'] = filtered_data
                logger.info(f"Kanal {channel_id} için {len(filtered_data)} log kaydı filtrelendi")
            
            return channel_logs
            
        except Exception as e:
            logger.error(f"Log verisi okuma hatası: {e}")
            logger.error(traceback.format_exc())
            return None

    def _get_channel_name(self, channel_id: int) -> str:
        """Kanal ID'sine göre kanal adını getir"""
        try:
            channel_file_path = os.path.join(self.variable_path, "channel.json")
            if os.path.exists(channel_file_path):
                channel_data = self._read_json_file(channel_file_path)
                if channel_data:
                    channels = channel_data.get('channel', [])
                    for channel in channels:
                        if channel.get('id') == channel_id:
                            return channel.get('name', f'Kanal {channel_id}')
            
            return f'Kanal {channel_id}'
            
        except Exception as e:
            logger.error(f"Kanal adı getirme hatası: {e}")
            return f'Kanal {channel_id}'

    def check_alarms(self) -> List[Dict[str, Any]]:
        """Alarm durumlarını kontrol et ve log verilerini kaydet"""
        try:
            logger.info("Alarm durumları kontrol ediliyor...")
            
            # Alarm verilerini oku
            alarm_data = self.get_alarm_data()
            if not alarm_data:
                logger.info("Alarm verisi bulunamadı")
                return []
            
            # Data verilerini oku
            data_file_path = os.path.join(self.variable_path, "data.json")
            if not os.path.exists(data_file_path):
                logger.warning("Data.json dosyası bulunamadı")
                return []
            
            data_content = self._read_json_file(data_file_path)
            if not data_content:
                logger.warning("Data.json dosyası okunamadı")
                return []
            
            active_alarms = []
            data_entries = data_content.get('data', [])
            
            for data_entry in data_entries:
                channel_id = data_entry.get('channel')
                value = data_entry.get('value', 0)
                
                if channel_id is None:
                    continue
                
                # Log verisini kaydet
                self.save_log_data(channel_id, value)
                
                # Alarm kontrolü
                channel_alarms = alarm_data.get(f'parameter1', {}).get(str(channel_id), {}).get('alarms', [])
                
                for alarm in channel_alarms:
                    min_value = alarm.get('min_value', 0)
                    max_value = alarm.get('max_value', 0)
                    color = alarm.get('color', '#FF0000')
                    
                    # Değer alarm aralığında mı kontrol et
                    if min_value <= value <= max_value:
                        alarm_info = {
                            'channel_id': channel_id,
                            'channel_name': self._get_channel_name(channel_id),
                            'value': value,
                            'min_value': min_value,
                            'max_value': max_value,
                            'color': color,
                            'timestamp': datetime.now().isoformat()
                        }
                        active_alarms.append(alarm_info)
                        logger.info(f"Alarm tetiklendi: Kanal {channel_id}, Değer: {value}, Aralık: {min_value}-{max_value}")
            
            return active_alarms
            
        except Exception as e:
            logger.error(f"Alarm kontrol hatası: {e}")
            logger.error(traceback.format_exc())
            return []

    def auto_save_logs_from_data(self) -> bool:
        """Data.json dosyasındaki verileri otomatik olarak log verilerine kaydet"""
        try:
            logger.info("Data.json dosyasından log verileri otomatik olarak kaydediliyor...")
            
            # Data verilerini oku
            data_file_path = os.path.join(self.variable_path, "data.json")
            if not os.path.exists(data_file_path):
                logger.warning("Data.json dosyası bulunamadı")
                return False
            
            data_content = self._read_json_file(data_file_path)
            if not data_content:
                logger.warning("Data.json dosyası okunamadı")
                return False
            
            # Mevcut log verilerini oku
            logs_file_path = os.path.join(self.logsfile_path, "logs.json")
            if os.path.exists(logs_file_path):
                try:
                    with open(logs_file_path, 'r', encoding='utf-8') as file:
                        logs_content = json.load(file)
                except (json.JSONDecodeError, FileNotFoundError):
                    logs_content = {"logs": {}}
            else:
                logs_content = {"logs": {}}
            
            data_entries = data_content.get('data', [])
            saved_count = 0
            
            for data_entry in data_entries:
                channel_id = data_entry.get('channel')
                value = data_entry.get('value', 0)
                value_timestamp = data_entry.get('value_timestamp', 0)
                
                if channel_id is None:
                    continue
                
                # Kanal için mevcut log verilerini kontrol et
                channel_key = f"channel_{channel_id}"
                logs = logs_content.get('logs', {})
                
                if channel_key not in logs:
                    logs[channel_key] = {
                        "channel_id": channel_id,
                        "channel_name": self._get_channel_name(channel_id),
                        "data": []
                    }
                
                existing_logs = logs[channel_key].get('data', [])
                
                # Timestamp'i belirle
                if value_timestamp:
                    # Unix timestamp'i ISO formatına çevir
                    timestamp = datetime.fromtimestamp(value_timestamp).strftime("%Y-%m-%dT%H:%M:%SZ")
                else:
                    timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
                
                # Duplicate kontrolü - aynı value, timestamp, min_value ve max_value'ya sahip kayıt var mı?
                is_duplicate = False
                min_value = data_entry.get('min_value', 0)
                max_value = data_entry.get('max_value', 0)
                
                for existing_log in existing_logs:
                    if (existing_log.get('value') == value and 
                        existing_log.get('timestamp') == timestamp and
                        existing_log.get('min_value') == min_value and
                        existing_log.get('max_value') == max_value):
                        is_duplicate = True
                        break
                
                if is_duplicate:
                    logger.debug(f"Kanal {channel_id} için duplicate kayıt tespit edildi: {value} - {timestamp}")
                    continue
                
                # Son log kaydını kontrol et
                last_log = existing_logs[-1] if existing_logs else None
                
                # Eğer son log kaydı yoksa veya değer/min/max değişmişse yeni kayıt ekle
                should_add = False
                min_value = data_entry.get('min_value', 0)
                max_value = data_entry.get('max_value', 0)
                
                if last_log is None:
                    should_add = True
                    logger.info(f"Kanal {channel_id} için ilk log kaydı ekleniyor: {value}")
                elif last_log.get('value') != value:
                    should_add = True
                    logger.info(f"Kanal {channel_id} için değer değişikliği tespit edildi: {last_log.get('value')} -> {value}")
                elif last_log.get('min_value') != min_value:
                    should_add = True
                    logger.info(f"Kanal {channel_id} için min_value değişikliği tespit edildi: {last_log.get('min_value')} -> {min_value}")
                elif last_log.get('max_value') != max_value:
                    should_add = True
                    logger.info(f"Kanal {channel_id} için max_value değişikliği tespit edildi: {last_log.get('max_value')} -> {max_value}")
                elif last_log.get('timestamp') != timestamp:
                    # Aynı değer ama farklı timestamp varsa da ekle
                    should_add = True
                    logger.info(f"Kanal {channel_id} için timestamp değişikliği tespit edildi: {timestamp}")
                
                if should_add:
                    # Yeni log kaydı için ID bul
                    existing_ids = [log.get('id') for log in existing_logs if log.get('id') is not None]
                    new_log_id = max(existing_ids) + 1 if existing_ids else 1
                    
                    # Yeni log kaydı oluştur
                    new_log_entry = {
                        "id": new_log_id,
                        "timestamp": timestamp,
                        "value": value,
                        "min_value": data_entry.get('min_value', 0),
                        "max_value": data_entry.get('max_value', 0)
                    }
                    
                    # Log kaydını listeye ekle
                    logs[channel_key]['data'].append(new_log_entry)
                    saved_count += 1
                    logger.info(f"Kanal {channel_id} için yeni log verisi kaydedildi: {value}")
            
            # Değişiklik varsa dosyayı kaydet
            if saved_count > 0:
                logs_content['logs'] = logs
                with open(logs_file_path, 'w', encoding='utf-8') as file:
                    json.dump(logs_content, file, indent=2, ensure_ascii=False)
                
                # Dosya değişiklik zamanını güncelle
                self.file_last_modified[logs_file_path] = os.path.getmtime(logs_file_path)
                logger.info(f"Toplam {saved_count} yeni log verisi kaydedildi")
            else:
                logger.info("Yeni log verisi bulunamadı, mevcut veriler güncel")
            
            return saved_count > 0
            
        except Exception as e:
            logger.error(f"Otomatik log kaydetme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def check_data_changes(self) -> bool:
        """Data.json dosyasındaki değişiklikleri kontrol et ve log verilerini otomatik olarak kaydet"""
        try:
            data_file_path = os.path.join(self.variable_path, "data.json")
            
            if not os.path.exists(data_file_path):
                return False
            
            # Dosyanın son değiştirilme zamanını kontrol et
            current_mtime = os.path.getmtime(data_file_path)
            last_mtime = self.file_last_modified.get(data_file_path, 0)
            
            if current_mtime > last_mtime:
                logger.info("Data.json dosyasında değişiklik tespit edildi, log verileri otomatik olarak kaydediliyor...")
                
                # Log verilerini otomatik olarak kaydet
                success = self.auto_save_logs_from_data()
                
                # Dosya değişiklik zamanını güncelle
                self.file_last_modified[data_file_path] = current_mtime
                
                if success:
                    logger.info("Log verileri başarıyla otomatik olarak kaydedildi")
                else:
                    logger.warning("Log verileri otomatik olarak kaydedilemedi")
                
                return True
            
            return False
            
        except Exception as e:
            logger.error(f"Data değişiklik kontrolü hatası: {e}")
            return False

    def save_variable_data(self, variable_data: Dict[str, Any]) -> bool:
        """Variable data'yı güncellenmiş min/max değerleriyle kaydet"""
        try:
            logger.info("Variable data güncellenmiş min/max değerleriyle kaydediliyor")
            
            # Data.json dosyasını oku
            data_file_path = os.path.join(self.variable_path, "data.json")
            current_data = self._read_json_file(data_file_path)
            
            if not current_data:
                current_data = {"data": []}
            
            # Güncellenmiş veriyi kaydet
            current_data["data"] = variable_data.get("data", [])
            
            # Dosyaya kaydet
            with open(data_file_path, 'w', encoding='utf-8') as file:
                json.dump(current_data, file, indent=2, ensure_ascii=False)
            
            logger.info("Variable data başarıyla güncellendi")
            return True
            
        except Exception as e:
            logger.error(f"Variable data kaydetme hatası: {e}")
            logger.error(traceback.format_exc())
            return False

    def get_station_data(self) -> Optional[Dict[str, Any]]:
        """Station verilerini getir"""
        try:
            file_path = os.path.join(self.semi_variable_path, "station.json")
            station_data = self._read_json_file(file_path)
            
            if station_data is None or not station_data:
                logger.warning("Station.json dosyası okunamadı veya boş")
                return {"station": []}
            
            logger.info("Station verileri başarıyla getirildi")
            return station_data
            
        except Exception as e:
            logger.error(f"Station verileri getirme hatası: {e}")
            return {"station": []}

    def get_station_by_id(self, station_id: int) -> Optional[Dict[str, Any]]:
        """Belirtilen ID'li istasyon bilgisini getir"""
        try:
            file_path = os.path.join(self.semi_variable_path, "station.json")
            station_data = self._read_json_file(file_path)
            
            if station_data is None or not station_data:
                logger.warning("Station.json dosyası okunamadı veya boş")
                return None
            
            if 'station' in station_data and station_data['station']:
                for station in station_data['station']:
                    if station.get('id') == station_id:
                        logger.info(f"ID {station_id} olan istasyon bulundu")
                        return station
            
            logger.warning(f"ID {station_id} olan istasyon bulunamadı")
            return None
            
        except Exception as e:
            logger.error(f"Station ID {station_id} getirme hatası: {e}")
            return None

    def get_semi_variable_data(self) -> Optional[Dict[str, Any]]:
        """Semi-variable klasöründeki tüm verileri getir"""
        try:
            return self._read_directory_files(self.semi_variable_path, "semi-variable")
        except Exception as e:
            logger.error(f"Semi-variable veri getirme hatası: {e}")
            return {}

    def get_data_json_data(self) -> Optional[Dict[str, Any]]:
        """Data.json dosyasındaki verileri getir"""
        try:
            file_path = os.path.join(self.variable_path, "data.json")
            data = self._read_json_file(file_path)
            
            if data is None or not data:
                logger.warning("Data.json dosyası okunamadı veya boş")
                return {"data": []}
            
            logger.info("Data.json verileri başarıyla getirildi")
            return data
            
        except Exception as e:
            logger.error(f"Data.json veri getirme hatası: {e}")
            return {"data": []}

    def get_channel_json_data(self) -> Optional[Dict[str, Any]]:
        """Channel.json dosyasındaki verileri getir"""
        try:
            file_path = os.path.join(self.variable_path, "channel.json")
            data = self._read_json_file(file_path)
            
            if data is None or not data:
                logger.warning("Channel.json dosyası okunamadı veya boş")
                return {"channel": []}
            
            logger.info("Channel.json verileri başarıyla getirildi")
            return data
            
        except Exception as e:
            logger.error(f"Channel.json veri getirme hatası: {e}")
            return {"channel": []}

    def get_channels(self) -> List[Dict[str, Any]]:
        """Tüm kanalları getir"""
        try:
            file_path = os.path.join(self.variable_path, "channel.json")
            channel_data = self._read_json_file(file_path)
            
            if channel_data is None or not channel_data:
                logger.warning("Channel.json dosyası okunamadı veya boş")
                return []
            
            if 'channel' in channel_data and channel_data['channel']:
                logger.info(f"{len(channel_data['channel'])} kanal bulundu")
                return channel_data['channel']
            
            logger.warning("Kanal verisi bulunamadı")
            return []
            
        except Exception as e:
            logger.error(f"Kanal verileri getirme hatası: {e}")
            return []

    def get_channel(self, channel_id: int) -> Optional[Dict[str, Any]]:
        """Belirtilen ID'li kanal bilgisini getir"""
        try:
            file_path = os.path.join(self.variable_path, "channel.json")
            channel_data = self._read_json_file(file_path)
            
            if channel_data is None or not channel_data:
                logger.warning("Channel.json dosyası okunamadı veya boş")
                return None
            
            if 'channel' in channel_data and channel_data['channel']:
                for channel in channel_data['channel']:
                    if channel.get('id') == channel_id:
                        logger.info(f"ID {channel_id} olan kanal bulundu")
                        return channel
            
            logger.warning(f"ID {channel_id} olan kanal bulunamadı")
            return None
            
        except Exception as e:
            logger.error(f"Kanal ID {channel_id} getirme hatası: {e}")
            return None

    def get_data(self) -> List[Dict[str, Any]]:
        """Tüm anlık verileri getir"""
        try:
            file_path = os.path.join(self.variable_path, "data.json")
            data_json = self._read_json_file(file_path)
            
            if data_json is None or not data_json:
                logger.warning("Data.json dosyası okunamadı veya boş")
                return []
            
            if 'data' in data_json and data_json['data']:
                logger.info(f"{len(data_json['data'])} anlık veri bulundu")
                return data_json['data']
            
            logger.warning("Anlık veri bulunamadı")
            return []
            
        except Exception as e:
            logger.error(f"Anlık veri getirme hatası: {e}")
            return []

    def get_channel_data(self, channel_id: int) -> List[Dict[str, Any]]:
        """Belirtilen kanal ID'sine ait anlık verileri getir"""
        try:
            file_path = os.path.join(self.variable_path, "data.json")
            data_json = self._read_json_file(file_path)
            
            if data_json is None or not data_json:
                logger.warning("Data.json dosyası okunamadı veya boş")
                return []
            
            if 'data' in data_json and data_json['data']:
                channel_data = [
                    item for item in data_json['data'] 
                    if item.get('channel') == channel_id
                ]
                logger.info(f"Kanal {channel_id} için {len(channel_data)} anlık veri bulundu")
                return channel_data
            
            logger.warning(f"Kanal {channel_id} için anlık veri bulunamadı")
            return []
            
        except Exception as e:
            logger.error(f"Kanal {channel_id} anlık veri getirme hatası: {e}")
            return []