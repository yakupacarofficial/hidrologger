import json
import os
import logging
from typing import Dict, List, Any
from datetime import datetime

logger = logging.getLogger(__name__)

class JSONReader:
    def __init__(self, base_path: str = "jsons"):
        self.base_path = base_path
        self.constant_path = os.path.join(base_path, "constant")
        self.variable_path = os.path.join(base_path, "variable")
        
    def read_json_file(self, file_path: str) -> Dict[str, Any]:
        """JSON dosyasını oku"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return json.load(file)
        except FileNotFoundError:
            logger.error(f"Dosya bulunamadı: {file_path}")
            return {}
        except json.JSONDecodeError as e:
            logger.error(f"JSON okuma hatası {file_path}: {e}")
            return {}
        except Exception as e:
            logger.error(f"Beklenmeyen hata {file_path}: {e}")
            return {}
    
    def read_constant_data(self) -> Dict[str, Any]:
        """Tüm constant JSON dosyalarını oku"""
        constant_data = {}
        
        # Constant klasöründeki tüm JSON dosyalarını oku
        if os.path.exists(self.constant_path):
            for filename in os.listdir(self.constant_path):
                if filename.endswith('.json'):
                    file_path = os.path.join(self.constant_path, filename)
                    data = self.read_json_file(file_path)
                    if data:
                        # Dosya adını key olarak kullan (uzantısız)
                        key = filename.replace('.json', '')
                        constant_data[key] = data
                        logger.info(f"Constant veri yüklendi: {key}")
        
        return constant_data
    
    def read_variable_data(self) -> Dict[str, Any]:
        """Variable JSON dosyalarını oku"""
        variable_data = {}
        
        # Variable klasöründeki tüm JSON dosyalarını oku
        if os.path.exists(self.variable_path):
            for filename in os.listdir(self.variable_path):
                if filename.endswith('.json'):
                    file_path = os.path.join(self.variable_path, filename)
                    data = self.read_json_file(file_path)
                    if data:
                        key = filename.replace('.json', '')
                        variable_data[key] = data
                        logger.info(f"Variable veri yüklendi: {key}")
        
        return variable_data
    
    def combine_data(self) -> Dict[str, Any]:
        """Constant ve variable verileri birleştir"""
        constant_data = self.read_constant_data()
        variable_data = self.read_variable_data()
        
        combined_data = {
            "timestamp": datetime.now().isoformat(),
            "constant": constant_data,
            "variable": variable_data
        }
        
        return combined_data
    
    def get_channel_info(self, channel_id: int) -> Dict[str, Any]:
        """Belirli bir kanalın bilgilerini getir"""
        constant_data = self.read_constant_data()
        
        if 'channel' in constant_data:
            for channel in constant_data['channel'].get('channel', []):
                if channel.get('id') == channel_id:
                    return channel
        
        return {}
    
    def get_station_info(self) -> Dict[str, Any]:
        """İstasyon bilgilerini getir"""
        constant_data = self.read_constant_data()
        return constant_data.get('station', {}).get('station', [{}])[0] if constant_data.get('station', {}).get('station') else {} 