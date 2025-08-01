import asyncio
import websockets
import json
import logging
import signal
import sys
from datetime import datetime
from json_reader import JSONReader

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
        self.json_reader = JSONReader()
        self.server = None
        self.broadcast_task = None
    
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
    
    async def generate_data(self):
        """JSON dosyalarından veri üret"""
        try:
            combined_data = self.json_reader.combine_data()
            logger.info("JSON verileri başarıyla okundu ve birleştirildi")
            return combined_data
        except Exception as e:
            logger.error(f"Veri üretme hatası: {e}")
            return {
                "timestamp": datetime.now().isoformat(),
                "error": "Veri okuma hatası",
                "constant": {},
                "variable": {}
            }
    
    async def broadcast_loop(self):
        """Veri yayınlama döngüsü"""
        while self.is_running:
            try:
                data = await self.generate_data()
                await self.broadcast_data(data)
                logger.info("Veri yayınlandı")
                await asyncio.sleep(1)  # 1 saniye bekle
            except Exception as e:
                logger.error(f"Veri yayınlama hatası: {e}")
                await asyncio.sleep(1)
    
    async def start_server(self):
        """Sunucuyu başlat"""
        try:
            self.server = await websockets.serve(
                self.handle_client, 
                self.host, 
                self.port
            )
            self.is_running = True
            logger.info(f"WebSocket sunucusu başlatıldı: ws://{self.host}:{self.port}")
            logger.info("Sunucu çalışıyor... (Ctrl+C ile durdurun)")
            
            # Broadcast loop'u başlat
            self.broadcast_task = asyncio.create_task(self.broadcast_loop())
            
            await self.server.wait_closed()
        except Exception as e:
            logger.error(f"Sunucu başlatma hatası: {e}")
            self.is_running = False
    
    async def shutdown(self):
        """Sunucuyu güvenli şekilde kapat"""
        logger.info("Sunucu kapatılıyor...")
        self.is_running = False
        
        # Broadcast task'ı iptal et
        if self.broadcast_task and not self.broadcast_task.done():
            self.broadcast_task.cancel()
            try:
                await self.broadcast_task
            except asyncio.CancelledError:
                pass
        
        # Tüm client bağlantılarını kapat
        if self.clients:
            logger.info(f"{len(self.clients)} client bağlantısı kapatılıyor...")
            await asyncio.gather(
                *[client.close() for client in self.clients],
                return_exceptions=True
            )
            self.clients.clear()
        
        # Server'ı kapat
        if self.server:
            self.server.close()
            await self.server.wait_closed()
        
        logger.info("Sunucu başarıyla kapatıldı")

async def main():
    server = WebSocketServer()
    
    # Signal handler'ları ayarla
    def signal_handler(signum, frame):
        logger.info(f"Sinyal alındı: {signum}")
        asyncio.create_task(server.shutdown())
    
    # SIGINT (Ctrl+C) ve SIGTERM sinyallerini yakala
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    try:
        # Sunucuyu başlat
        await server.start_server()
    except KeyboardInterrupt:
        logger.info("KeyboardInterrupt alındı...")
        await server.shutdown()
    except Exception as e:
        logger.error(f"Ana döngü hatası: {e}")
        await server.shutdown()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Program sonlandırıldı")
    except Exception as e:
        logger.error(f"Program hatası: {e}")
    finally:
        logger.info("Program tamamen kapatıldı") 