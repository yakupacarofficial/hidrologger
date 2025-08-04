import json
import os
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
import traceback
import time

logger = logging.getLogger(__name__)

class JSONReader:
    def __init__(self, base_path: str = "jsons"):
        # Eğer jsons klasörü mevcut değilse, python_server/jsons'u dene
        if not os.path.exists(base_path) and os.path.exists(os.path.join("python_server", base_path)):
            base_path = os.path.join("python_server", base_path)
        
        self.base_path = base_path
        self.alarm_path = os.path.join(base_path, "alarm")
        self.constant_path = os.path.join(base_path, "constant")
        self.variable_path = os.path.join(base_path, "variable")
        
        # Dosya izleme için
        self.file_last_modified = {}
        self.last_successful_data = None
        self.last_check_time = 0
        self.check_interval = 1.0  # Saniye cinsinden kontrol aralığı
        
        # Veri geçmişi için
        self.data_history = {}  # {channel_id: [data_list]}
        self.max_history_size = 50  # Her kanal için maksimum 50 veri noktası
        
        # Başlangıçta tüm dosyaları tara
        self._initialize_file_tracking()
        
        logger.info("JSONReader başlatıldı")
        logger.info(f"Alarm klasörü: {self.alarm_path}")
        logger.info(f"Constant klasörü: {self.constant_path}")
        logger.info(f"Variable klasörü: {self.variable_path}")
        logger.info(f"Veri geçmişi sistemi aktif - Maksimum {self.max_history_size} veri noktası/kanal")
    
    def _initialize_file_tracking(self):
        """Tüm JSON dosyalarının son değiştirilme zamanlarını kaydet"""
        for folder_path in [self.alarm_path, self.constant_path, self.variable_path]:
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
                return None
                
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read().strip()
                if not content:
                    logger.warning(f"Dosya boş: {file_path}")
                    return None
                    
                data = json.loads(content)
                logger.debug(f"Dosya başarıyla okundu: {file_path}")
                return data
                
        except json.JSONDecodeError as e:
            logger.error(f"JSON parse hatası {file_path}: {e}")
            return None
        except Exception as e:
            logger.error(f"Dosya okuma hatası {file_path}: {e}")
            return None
    
    def _read_directory_files(self, directory_path: str, category_name: str) -> Dict[str, Any]:
        """Bir klasördeki tüm JSON dosyalarını oku"""
        result = {}
        
        if not os.path.exists(directory_path):
            logger.warning(f"{category_name} klasörü bulunamadı: {directory_path}")
            return result
        
        try:
            files = [f for f in os.listdir(directory_path) if f.endswith('.json')]
            logger.info(f"{category_name} klasöründe {len(files)} JSON dosyası bulundu")
            
            for filename in files:
                file_path = os.path.join(directory_path, filename)
                file_key = os.path.splitext(filename)[0]  # .json uzantısını kaldır
                
                data = self._read_json_file(file_path)
                if data is not None:
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
                else:
                    logger.error(f"{category_name} verisi yüklenemedi: {file_key}")
                    
        except Exception as e:
            logger.error(f"{category_name} klasörü okuma hatası: {e}")
            
        return result
    
    def _has_files_changed(self) -> bool:
        """Dosyalarda değişiklik olup olmadığını kontrol et"""
        current_time = time.time()
        
        # Kontrol aralığını kontrol et
        if current_time - self.last_check_time < self.check_interval:
            return False
            
        self.last_check_time = current_time
        
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
        for folder_path in [self.alarm_path, self.constant_path, self.variable_path]:
            if os.path.exists(folder_path):
                for filename in os.listdir(folder_path):
                    if filename.endswith('.json'):
                        file_path = os.path.join(folder_path, filename)
                        if file_path not in self.file_last_modified:
                            logger.info(f"Yeni dosya tespit edildi: {file_path}")
                            self.file_last_modified[file_path] = os.path.getmtime(file_path)
                            return True
        
        return False
    
    def read_all_data(self) -> Optional[Dict[str, Any]]:
        """Tüm JSON verilerini oku ve birleştir"""
        try:
            # Dosya değişikliği kontrolü
            if not self._has_files_changed() and self.last_successful_data is not None:
                logger.debug("Dosya değişikliği yok, önbellek kullanılıyor")
                return self.last_successful_data
            
            logger.info("JSON dosyaları okunuyor...")
            
            # Tüm klasörlerden verileri oku
            alarm_data = self._read_directory_files(self.alarm_path, "Alarm")
            constant_data = self._read_directory_files(self.constant_path, "Constant")
            variable_data = self._read_directory_files(self.variable_path, "Variable")
            
            # Verileri birleştir
            combined_data = {
                "timestamp": datetime.now().isoformat(),
                "alarm": alarm_data,
                "constant": constant_data,
                "variable": variable_data
            }
            
            # Veri boyutunu hesapla
            data_size = len(json.dumps(combined_data, ensure_ascii=False))
            logger.info(f"Birleştirilmiş veri boyutu: {data_size} byte")
            
            # Veri doğrulama
            if self._validate_data(combined_data):
                # Variable data'yı geçmiş verilerle birleştir
                variable_data = combined_data.get('variable', {})
                data_list = variable_data.get('data', [])
                
                # Geçmiş verileri güncelle
                if data_list:
                    self.update_data_history(data_list)
                
                # Geçmiş verileri combined_data'ya ekle
                combined_data['data_history'] = self.data_history
                
                self.last_successful_data = combined_data
                logger.info("JSON verileri başarıyla okundu ve birleştirildi (geçmiş veriler dahil)")
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
        """Veri bütünlüğünü kontrol et"""
        try:
            # Temel yapı kontrolü
            required_keys = ["timestamp", "alarm", "constant", "variable"]
            for key in required_keys:
                if key not in data:
                    logger.error(f"Eksik anahtar: {key}")
                    return False
            
            # Timestamp kontrolü
            if not data["timestamp"]:
                logger.error("Timestamp boş")
                return False
            
            # En az bir veri kategorisinin dolu olması gerekiyor
            has_data = False
            for category in ["alarm", "constant", "variable"]:
                if data[category] and len(data[category]) > 0:
                    has_data = True
                    break
            
            if not has_data:
                logger.error("Hiçbir kategoride veri bulunamadı")
                return False
            
            logger.debug("Veri doğrulama başarılı")
            return True
            
        except Exception as e:
            logger.error(f"Veri doğrulama hatası: {e}")
            return False
    
    def get_data_summary(self) -> Dict[str, Any]:
        """Veri özetini döndür"""
        if self.last_successful_data is None:
            return {"status": "no_data"}
        
        try:
            summary = {
                "status": "success",
                "timestamp": self.last_successful_data.get("timestamp"),
                "categories": {
                    "alarm": len(self.last_successful_data.get("alarm", {})),
                    "constant": len(self.last_successful_data.get("constant", {})),
                    "variable": len(self.last_successful_data.get("variable", {}))
                },
                "total_files": len(self.file_last_modified),
                "data_size_bytes": len(json.dumps(self.last_successful_data, ensure_ascii=False))
            }
            return summary
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

    def update_channel_field(self, channel_id: int, field: str, value: Any) -> bool:
        """Kanal bilgilerini güncelle"""
        try:
            logger.info(f"Kanal güncelleme: ID={channel_id}, Field={field}, Value={value}")
            
            # Channel dosyasının yolunu belirle
            channel_file_path = os.path.join(self.constant_path, "channel.json")
            
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
    
    def update_data_history(self, variable_data: List[Dict[str, Any]]) -> None:
        """Veri geçmişini güncelle"""
        try:
            for data_item in variable_data:
                channel_id = data_item.get('channel', 0)
                
                if channel_id not in self.data_history:
                    self.data_history[channel_id] = []
                
                # Yeni veriyi ekle
                self.data_history[channel_id].append(data_item)
                
                # Maksimum boyutu aşarsa en eski veriyi kaldır
                if len(self.data_history[channel_id]) > self.max_history_size:
                    self.data_history[channel_id].pop(0)
                
            logger.debug(f"Veri geçmişi güncellendi - Toplam kanal sayısı: {len(self.data_history)}")
            
        except Exception as e:
            logger.error(f"Veri geçmişi güncelleme hatası: {e}")
    
    def get_data_history(self, channel_id: int = None) -> Dict[str, Any]:
        """Veri geçmişini döndür"""
        try:
            if channel_id is not None:
                # Belirli bir kanalın geçmişini döndür
                return {
                    "channel_id": channel_id,
                    "history": self.data_history.get(channel_id, []),
                    "count": len(self.data_history.get(channel_id, []))
                }
            else:
                # Tüm kanalların geçmişini döndür
                return {
                    "all_history": self.data_history,
                    "total_channels": len(self.data_history),
                    "total_data_points": sum(len(history) for history in self.data_history.values())
                }
                
        except Exception as e:
            logger.error(f"Veri geçmişi alma hatası: {e}")
            return {}
    
    def get_combined_data_with_history(self) -> Optional[Dict[str, Any]]:
        """Mevcut verileri geçmiş verilerle birleştirerek döndür"""
        try:
            # Mevcut verileri al
            current_data = self.read_all_data()
            if current_data is None:
                return None
            
            # Variable data'yı geçmiş verilerle birleştir
            variable_data = current_data.get('variable', {})
            data_list = variable_data.get('data', [])
            
            # Geçmiş verileri güncelle
            if data_list:
                self.update_data_history(data_list)
            
            # Birleştirilmiş veriyi oluştur
            combined_data = current_data.copy()
            
            # Her kanal için geçmiş verileri ekle
            for channel_id, history in self.data_history.items():
                # Mevcut verilerde bu kanalın verisi var mı kontrol et
                current_channel_data = [d for d in data_list if d.get('channel') == channel_id]
                
                if current_channel_data:
                    # Mevcut veriyi geçmişin sonuna ekle (eğer yoksa)
                    latest_data = current_channel_data[0]
                    if not history or history[-1] != latest_data:
                        history.append(latest_data)
                        if len(history) > self.max_history_size:
                            history.pop(0)
            
            # Geçmiş verileri combined_data'ya ekle
            combined_data['data_history'] = self.data_history
            
            logger.debug(f"Birleştirilmiş veri oluşturuldu - {len(self.data_history)} kanal geçmişi")
            return combined_data
            
        except Exception as e:
            logger.error(f"Birleştirilmiş veri oluşturma hatası: {e}")
            return None
    
    def save_alarm_data(self, alarm_data: Dict[str, Any]) -> bool:
        """Alarm verilerini kaydet"""
        try:
            logger.info(f"Alarm verileri kaydediliyor: {alarm_data}")
            
            # Alarm dosyasının yolunu belirle
            alarm_file_path = os.path.join(self.alarm_path, "alarm.json")
            logger.info(f"Alarm dosya yolu: {alarm_file_path}")
            logger.info(f"Dosya mevcut mu: {os.path.exists(alarm_file_path)}")
            
            if not os.path.exists(alarm_file_path):
                logger.error(f"Alarm dosyası bulunamadı: {alarm_file_path}")
                return False
            
            # Mevcut alarm verilerini oku
            with open(alarm_file_path, 'r', encoding='utf-8') as file:
                current_data = json.load(file)
            
            # Yeni verileri güncelle
            logger.info(f"Mevcut veri: {current_data}")
            logger.info(f"Gelen alarm verisi: {alarm_data}")
            
            # Ana alanları güncelle
            if 'istCode' in alarm_data:
                current_data['istCode'] = alarm_data['istCode']
            if 'securityCode' in alarm_data:
                current_data['securityCode'] = alarm_data['securityCode']
            if 'parameter' in alarm_data:
                current_data['parameter'] = alarm_data['parameter']
            
            # DeviceSettings'i güncelle
            device_settings = current_data.get('deviceSettings', {})
            new_device_settings = alarm_data.get('deviceSettings', {})
            
            logger.info(f"Mevcut deviceSettings: {device_settings}")
            logger.info(f"Yeni deviceSettings: {new_device_settings}")
            
            # DeviceSettings alanlarını güncelle
            if 'dataPostFrequency' in new_device_settings:
                device_settings['dataPostFrequency'] = new_device_settings['dataPostFrequency']
            if 'yellowAlert' in new_device_settings:
                device_settings['yellowAlert'] = new_device_settings['yellowAlert']
            if 'orangeAlert' in new_device_settings:
                device_settings['orangeAlert'] = new_device_settings['orangeAlert']
            if 'redAlert' in new_device_settings:
                device_settings['redAlert'] = new_device_settings['redAlert']
            
            current_data['deviceSettings'] = device_settings
            
            # Dosyayı geri yaz
            logger.info(f"Güncellenmiş veri: {current_data}")
            with open(alarm_file_path, 'w', encoding='utf-8') as file:
                json.dump(current_data, file, indent=2, ensure_ascii=False)
            
            # Dosya değişiklik zamanını güncelle
            self.file_last_modified[alarm_file_path] = os.path.getmtime(alarm_file_path)
            
            # Cache'i temizle
            self.last_successful_data = None
            
            logger.info("Alarm verileri başarıyla kaydedildi")
            logger.info(f"Dosya yazıldı: {alarm_file_path}")
            return True
            
        except Exception as e:
            logger.error(f"Alarm verileri kaydetme hatası: {e}")
            logger.error(traceback.format_exc())
            return False