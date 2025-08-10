#!/usr/bin/env python3
"""
Log verilerinin otomatik olarak kaydedilmesini test etmek için script
"""

import json
import time
from datetime import datetime
from json_reader import JSONReader

def test_log_generation():
    """Log verilerinin otomatik olarak kaydedilmesini test et"""
    print("Log verisi kaydetme testi başlatılıyor...")
    
    # JSONReader'ı başlat
    json_reader = JSONReader()
    
    # Test verileri
    test_data = [
        {"channel_id": 1, "value": 25.5},
        {"channel_id": 2, "value": 30.2},
        {"channel_id": 3, "value": 15.8},
        {"channel_id": 1, "value": 26.1},
        {"channel_id": 2, "value": 31.5},
        {"channel_id": 3, "value": 16.2},
    ]
    
    print(f"{len(test_data)} test verisi kaydedilecek...")
    
    for i, data in enumerate(test_data, 1):
        channel_id = data["channel_id"]
        value = data["value"]
        
        print(f"Test {i}/{len(test_data)}: Kanal {channel_id} için değer {value} kaydediliyor...")
        
        # Log verisini kaydet
        success = json_reader.save_log_data(channel_id, value)
        
        if success:
            print(f"✅ Kanal {channel_id} için log verisi başarıyla kaydedildi")
        else:
            print(f"❌ Kanal {channel_id} için log verisi kaydedilemedi")
        
        # Kısa bir bekleme
        time.sleep(0.5)
    
    print("\nTest tamamlandı!")
    
    # Log verilerini kontrol et
    print("\nKaydedilen log verileri kontrol ediliyor...")
    
    for channel_id in [1, 2, 3]:
        log_data = json_reader.get_log_data(channel_id)
        if log_data:
            data_count = len(log_data.get('data', []))
            print(f"Kanal {channel_id}: {data_count} log kaydı bulundu")
        else:
            print(f"Kanal {channel_id}: Log verisi bulunamadı")

if __name__ == "__main__":
    test_log_generation()
