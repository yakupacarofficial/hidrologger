import requests
import json

def test_alarm_save():
    """Alarm kaydetme testi - Flutter formatında"""
    
    # Flutter'dan gelen alarm verisi formatı - Her alarmın kendi MS değeri var
    alarm_data = {
        "parameter1": {
            "channel_id": 1,
            "alarminfo": "Test Alarm",
            "alarms": [
                {
                    "min_value": 10.0,
                    "max_value": 50.0,
                    "color": "#FF0000",
                    "data_post_frequency": 1000
                },
                {
                    "min_value": 60.0,
                    "max_value": 80.0,
                    "color": "#00FF00",
                    "data_post_frequency": 500
                }
            ]
        }
    }
    
    try:
        # POST isteği gönder
        response = requests.post(
            'http://localhost:8765/api/data/alarm',
            json=alarm_data,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ Alarm başarıyla kaydedildi!")
            
            # Alarm.json dosyasını kontrol et
            alarm_response = requests.get('http://localhost:8765/api/data/alarm')
            if alarm_response.status_code == 200:
                alarm_data = alarm_response.json()
                print(f"📊 Alarm.json içeriği: {json.dumps(alarm_data, indent=2, ensure_ascii=False)}")
            else:
                print(f"❌ Alarm.json okuma hatası: {alarm_response.status_code}")
        else:
            print("❌ Alarm kaydetme başarısız!")
            
    except Exception as e:
        print(f"❌ Hata: {e}")

if __name__ == "__main__":
    test_alarm_save()
