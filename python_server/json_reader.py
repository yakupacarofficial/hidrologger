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
        
        # Başlangıçta tüm dosyaları tara
        self._initialize_file_tracking()
        
        logger.info("JSONReader başlatıldı")
        logger.info(f"Alarm klasörü: {self.alarm_path}")
        logger.info(f"Constant klasörü: {self.constant_path}")
        logger.info(f"Variable klasörü: {self.variable_path}")
    
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
                self.last_successful_data = combined_data
                logger.info("JSON verileri başarıyla okundu ve birleştirildi")
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