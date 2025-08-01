import asyncio
import websockets
import json

async def test_client():
    """WebSocket sunucusunu test et"""
    uri = "ws://localhost:8765"
    
    try:
        async with websockets.connect(uri) as websocket:
            print(f"✅ Sunucuya bağlandı: {uri}")
            
            # İlk 5 mesajı al
            for i in range(5):
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=2.0)
                    data = json.loads(message)
                    print(f"\n📡 Mesaj {i+1}:")
                    print(f"   Timestamp: {data.get('timestamp')}")
                    print(f"   Kanal Sayısı: {len(data.get('constant', {}).get('channel', {}).get('channel', []))}")
                    print(f"   Veri Sayısı: {len(data.get('variable', {}).get('data', {}).get('data', []))}")
                    
                    # İlk kanal bilgisini göster
                    channels = data.get('constant', {}).get('channel', {}).get('channel', [])
                    if channels:
                        first_channel = channels[0]
                        print(f"   İlk Kanal: {first_channel.get('name')} - {first_channel.get('description')}")
                    
                except asyncio.TimeoutError:
                    print(f"⏰ Mesaj {i+1}: Timeout")
                except Exception as e:
                    print(f"❌ Mesaj {i+1} hatası: {e}")
                    
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")

if __name__ == "__main__":
    print("🧪 WebSocket Sunucu Testi Başlıyor...")
    asyncio.run(test_client()) 