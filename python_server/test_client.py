import asyncio
import websockets
import json

async def test_client():
    """WebSocket sunucusunu test et"""
    uri = "ws://localhost:8765"
    
    try:
        async with websockets.connect(uri) as websocket:
            print(f"✅ Sunucuya bağlandı: {uri}")
            
            # İlk mesajı al ve göster
            try:
                message = await asyncio.wait_for(websocket.recv(), timeout=3.0)
                data = json.loads(message)
                print(f"\n📡 Alınan JSON Verisi:")
                print(json.dumps(data, indent=2, ensure_ascii=False))
                
                # Veri yapısını analiz et
                print("\n📊 Veri Analizi:")
                print(f"- Timestamp: {data.get('timestamp')}")
                
                # Alarm verilerini kontrol et
                alarm_data = data.get('alarm', {})
                print(f"- Alarm veri anahtarları: {list(alarm_data.keys())}")
                
                # Constant verilerini kontrol et
                constant_data = data.get('constant', {})
                print(f"- Constant veri anahtarları: {list(constant_data.keys())}")
                
                # Variable verilerini kontrol et
                variable_data = data.get('variable', {})
                print(f"- Variable veri anahtarları: {list(variable_data.keys())}")
                
                print(f"\n📈 Toplam veri boyutu: {len(json.dumps(data, ensure_ascii=False))} byte")
                
            except asyncio.TimeoutError:
                print(f"⏰ Mesaj alınamadı: Timeout")
            except Exception as e:
                print(f"❌ Mesaj işleme hatası: {e}")
                
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")

if __name__ == "__main__":
    asyncio.run(test_client())