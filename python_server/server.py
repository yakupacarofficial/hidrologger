import asyncio
import websockets
import json
import logging
from datetime import datetime

# Logging ayarları
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class WebSocketServer:
    def __init__(self, host='0.0.0.0', port=8765):
        self.host = host
        self.port = port
        self.clients = set()
        self.is_running = False
    
    async def handle_client(self, websocket, path):
        """Client bağlantısını yönet"""
        self.clients.add(websocket)
        client_address = websocket.remote_address
        logger.info(f"Yeni client bağlandı: {client_address}. Toplam client: {len(self.clients)}")
        
        try:
            async for message in websocket:
                # Client'tan gelen mesajları işle
                logger.info(f"Client mesajı ({client_address}): {message}")
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Client bağlantısı kapandı: {client_address}")
        except Exception as e:
            logger.error(f"Client hatası ({client_address}): {e}")
        finally:
            self.clients.remove(websocket)
            logger.info(f"Client ayrıldı: {client_address}. Kalan client: {len(self.clients)}")
    
    async def broadcast_data(self, data):
        """Tüm client'lara veri gönder"""
        if not self.clients:
            return
        
        message = json.dumps(data, ensure_ascii=False)
        logger.info(f"Veri yayınlanıyor: {message}")
        
        # Bağlantısı kopmuş client'ları temizle
        disconnected_clients = set()
        
        for client in self.clients:
            try:
                await client.send(message)
            except websockets.exceptions.ConnectionClosed:
                disconnected_clients.add(client)
            except Exception as e:
                logger.error(f"Veri gönderme hatası: {e}")
                disconnected_clients.add(client)
        
        # Kopmuş bağlantıları temizle
        self.clients -= disconnected_clients
        if disconnected_clients:
            logger.info(f"{len(disconnected_clients)} client bağlantısı temizlendi")
    
    async def generate_empty_data(self):
        """Boş JSON verisi üret - kullanıcı formatı belirttiğinde güncellenecek"""
        return {
            "timestamp": datetime.now().isoformat(),
            "data": {}
        }
    
    async def start_server(self):
        """Sunucuyu başlat"""
        try:
            server = await websockets.serve(
                self.handle_client, 
                self.host, 
                self.port
            )
            self.is_running = True
            logger.info(f"WebSocket sunucusu başlatıldı: ws://{self.host}:{self.port}")
            logger.info("Sunucu çalışıyor... (Ctrl+C ile durdurun)")
            
            await server.wait_closed()
        except Exception as e:
            logger.error(f"Sunucu başlatma hatası: {e}")
            self.is_running = False

async def main():
    server = WebSocketServer()
    
    # Veri yayınlama görevi
    async def broadcast_loop():
        while server.is_running:
            try:
                data = await server.generate_empty_data()
                await server.broadcast_data(data)
                await asyncio.sleep(1)  # 1 saniye bekle
            except Exception as e:
                logger.error(f"Veri yayınlama hatası: {e}")
                await asyncio.sleep(1)
    
    try:
        # Sunucu ve yayın görevlerini paralel çalıştır
        await asyncio.gather(
            server.start_server(),
            broadcast_loop()
        )
    except KeyboardInterrupt:
        logger.info("Sunucu durduruluyor...")
        server.is_running = False
    except Exception as e:
        logger.error(f"Ana döngü hatası: {e}")

if __name__ == "__main__":
    asyncio.run(main()) 