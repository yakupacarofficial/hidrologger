import requests
import json

def test_add_channel():
    """Yeni kanal ekleme testi"""
    
    # Test verisi - Kanal 4
    new_channel = {
        "id": 4,
        "name": "Test Kanal 4",
        "description": "Otomatik eklenen test kanalı",
        "channel_category": 1,
        "channel_sub_category": 1,
        "channel_parameter": 1,
        "measurement_unit": 1,
        "log_interval": 60,
        "offset": 0.0
    }
    
    try:
        # POST isteği gönder
        response = requests.post(
            'http://localhost:8765/api/channel',
            json=new_channel,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ Kanal başarıyla eklendi!")
            
            # Data.json dosyasını kontrol et
            data_response = requests.get('http://localhost:8765/api/data/variable')
            if data_response.status_code == 200:
                data = data_response.json()
                print(f"📊 Data.json içeriği: {json.dumps(data, indent=2, ensure_ascii=False)}")
            else:
                print(f"❌ Data.json okuma hatası: {data_response.status_code}")
        else:
            print("❌ Kanal ekleme başarısız!")
            
    except Exception as e:
        print(f"❌ Hata: {e}")

if __name__ == "__main__":
    test_add_channel()
