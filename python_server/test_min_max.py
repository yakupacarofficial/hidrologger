#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from json_reader import JSONReader

def test_min_max_calculation():
    """Min/max hesaplama işlemini test et"""
    reader = JSONReader()
    
    # Test verisi
    channel_id = 1
    
    print(f"Kanal {channel_id} için log verileri alınıyor...")
    logs_data = reader.get_log_data(channel_id)
    print(f"Logs data: {logs_data}")
    
    if logs_data and 'data' in logs_data and logs_data['data']:
        values = [log.get('value', 0) for log in logs_data['data']]
        print(f"Values: {values}")
        
        if values:
            min_value = min(values)
            max_value = max(values)
            print(f"Min value: {min_value}")
            print(f"Max value: {max_value}")
        else:
            print("Values listesi boş")
    else:
        print("Logs data bulunamadı veya data alanı yok")

if __name__ == "__main__":
    test_min_max_calculation()
