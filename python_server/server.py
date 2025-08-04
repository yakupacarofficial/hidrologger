import asyncio
import websockets
import json
import logging
import signal
import sys
import traceback
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
        self.broadcast_interval = 1.0  # Saniye cinsinden yayın aralığı
        
        # Başlangıçta veri yükle
        self._initialize_data()
    
    def _initialize_data(self):
        """Başlangıçta veri yükleme"""
        try:
            logger.info("Başlangıç veri yüklemesi yapılıyor...")
            data = self.json_reader.read_all_data()
            if data:
                logger.info("Başlangıç verileri başarıyla yüklendi")
                summary = self.json_reader.get_data_summary()
                logger.info(f"Veri özeti: {summary}")
            else:
                logger.warning("Başlangıç veri yüklemesi başarısız")
        except Exception as e:
            logger.error(f"Başlangıç veri yükleme hatası: {e}")
    
    async def handle_client(self, websocket, path):
        """Client bağlantısını yönet"""
        self.clients.add(websocket)
        client_address = websocket.remote_address
        logger.info(f"Yeni client bağlandı: {client_address}. Toplam client: {len(self.clients)}")
        
        try:
            # Yeni bağlanan client'a mevcut veriyi hemen gönder
            current_data = self.json_reader.read_all_data()
            if current_data:
                await self.send_to_client(websocket, current_data)
                logger.info(f"Mevcut veri client'a gönderildi: {client_address}")
            
            # Client'tan gelen mesajları dinle
            async for message in websocket:
                await self.handle_client_message(websocket, message)
                
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Client bağlantısı kapandı: {client_address}")
        except Exception as e:
            logger.error(f"Client hatası ({client_address}): {e}")
            logger.error(traceback.format_exc())
        finally:
            self.clients.discard(websocket)
            logger.info(f"Client ayrıldı: {client_address}. Kalan client: {len(self.clients)}")
    
    async def handle_client_message(self, websocket, message):
        """Client'tan gelen mesajları işle - DATA HISTORY KOMUTLARI KALDIRILDI"""
        try:
            client_address = websocket.remote_address
            logger.info(f"Client mesajı ({client_address}): {message}")
            
            # JSON mesajı parse et
            try:
                msg_data = json.loads(message)
                command = msg_data.get('command')
                
                if command == 'get_data':
                    # Mevcut veriyi gönder
                    current_data = self.json_reader.read_all_data()
                    if current_data:
                        await self.send_to_client(websocket, current_data)
                    else:
                        await self.send_error_to_client(websocket, "Veri bulunamadı")
                        
                elif command == 'get_summary':
                    # Veri özetini gönder
                    summary = self.json_reader.get_data_summary()
                    await self.send_to_client(websocket, {"type": "summary", "data": summary})
                    
                elif command == 'reload':
                    # Verileri zorla yeniden yükle
                    logger.info(f"Client tarafından zorla yeniden yükleme istendi: {client_address}")
                    data = self.json_reader.force_reload()
                    if data:
                        await self.send_to_client(websocket, data)
                    else:
                        await self.send_error_to_client(websocket, "Yeniden yükleme başarısız")
                        
                elif command == 'update_channel':
                    # Kanal bilgilerini güncelle
                    logger.info(f"Kanal güncelleme istendi: {client_address}")
                    channel_id = msg_data.get('channel_id')
                    field = msg_data.get('field')
                    value = msg_data.get('value')
                    
                    if channel_id is not None and field and value is not None:
                        success = self.json_reader.update_channel_field(channel_id, field, value)
                        if success:
                            # Güncellenmiş veriyi gönder
                            updated_data = self.json_reader.read_all_data()
                            await self.send_to_client(websocket, updated_data)
                            logger.info(f"Kanal {channel_id} güncellendi: {field} = {value}")
                        else:
                            await self.send_error_to_client(websocket, f"Kanal güncelleme başarısız: {channel_id}")
                    else:
                        await self.send_error_to_client(websocket, "Geçersiz kanal güncelleme parametreleri")
                        
                else:
                    await self.send_error_to_client(websocket, f"Bilinmeyen komut: {command}")
                    
            except json.JSONDecodeError:
                # JSON olmayan mesajlar için basit yanıt
                if message.strip().lower() in ['ping', 'hello', 'test']:
                    await websocket.send(json.dumps({"type": "pong", "message": "Server aktif"}))
                else:
                    await self.send_error_to_client(websocket, "Geçersiz JSON formatı")
                    
        except Exception as e:
            logger.error(f"Mesaj işleme hatası: {e}")
            await self.send_error_to_client(websocket, f"Mesaj işleme hatası: {str(e)}")
    
    async def send_to_client(self, websocket, data):
        """Tek bir client'a veri gönder"""
        try:
            json_data = json.dumps(data, ensure_ascii=False)
            await websocket.send(json_data)
        except Exception as e:
            logger.error(f"Client'a veri gönderme hatası: {e}")
    
    async def send_error_to_client(self, websocket, error_message):
        """Tek bir client'a hata mesajı gönder"""
        error_data = {
            "type": "error",
            "message": error_message,
            "timestamp": datetime.now().isoformat()
        }
        await self.send_to_client(websocket, error_data)
    
    async def broadcast_data(self, data):
        """Tüm client'lara veri gönder"""
        if not self.clients:
            logger.debug("Bağlı client yok, veri yayınlanmadı")
            return
        
        if not data:
            logger.warning("Yayınlanacak veri boş")
            return
        
        try:
            json_data = json.dumps(data, ensure_ascii=False)
            data_size = len(json_data)
            
            # Tüm client'lara gönder
            disconnected_clients = set()
            for client in self.clients.copy():
                try:
                    await client.send(json_data)
                except websockets.exceptions.ConnectionClosed:
                    disconnected_clients.add(client)
                except Exception as e:
                    logger.error(f"Client'a veri gönderme hatası: {e}")
                    disconnected_clients.add(client)
            
            # Bağlantısı kopan client'ları temizle
            for client in disconnected_clients:
                self.clients.discard(client)
            
            active_clients = len(self.clients)
            logger.info(f"Veri yayınlandı: {active_clients} client, {data_size} byte")
            
        except Exception as e:
            logger.error(f"Veri yayınlama hatası: {e}")
            logger.error(traceback.format_exc())
    
    async def broadcast_loop(self):
        """Sürekli veri yayınlama döngüsü"""
        logger.info(f"Veri yayınlama döngüsü başlatıldı (aralık: {self.broadcast_interval}s)")
        
        while self.is_running:
            try:
                # Veri oku
                data = self.json_reader.read_all_data()
                
                if data:
                    # Veri varsa yayınla
                    await self.broadcast_data(data)
                else:
                    # Veri yoksa hata mesajı yayınla
                    error_data = {
                        "type": "error",
                        "message": "Veri okunamadı",
                        "timestamp": datetime.now().isoformat()
                    }
                    await self.broadcast_data(error_data)
                    logger.warning("Veri okunamadı, hata mesajı yayınlandı")
                
                # Belirtilen aralıkta bekle
                await asyncio.sleep(self.broadcast_interval)
                
            except asyncio.CancelledError:
                logger.info("Yayınlama döngüsü iptal edildi")
                break
            except Exception as e:
                logger.error(f"Yayınlama döngüsü hatası: {e}")
                logger.error(traceback.format_exc())
                
                # Hata durumunda kısa bekle
                await asyncio.sleep(1.0)
        
        logger.info("Veri yayınlama döngüsü sonlandırıldı")
    
    async def start_server(self):
        """WebSocket sunucusunu başlat"""
        try:
            logger.info(f"WebSocket sunucusu başlatılıyor: {self.host}:{self.port}")
            
            # Sunucuyu başlat
            self.server = await websockets.serve(
                self.handle_client,
                self.host,
                self.port,
                ping_interval=20,
                ping_timeout=10
            )
            
            self.is_running = True
            logger.info(f"WebSocket sunucusu başlatıldı: ws://{self.host}:{self.port}")
            
            # Veri yayınlama döngüsünü başlat
            self.broadcast_task = asyncio.create_task(self.broadcast_loop())
            
            logger.info("Sunucu çalışıyor... (Ctrl+C ile durdurun)")
            
            # Sunucunun çalışmasını bekle
            await self.server.wait_closed()
            
        except Exception as e:
            logger.error(f"Sunucu başlatma hatası: {e}")
            logger.error(traceback.format_exc())
            raise
    
    async def shutdown(self):
        """Sunucuyu güvenli şekilde kapat"""
        logger.info("Sunucu kapatılıyor...")
        
        try:
            self.is_running = False
            
            # Yayınlama görevini iptal et
            if self.broadcast_task and not self.broadcast_task.done():
                self.broadcast_task.cancel()
                try:
                    await self.broadcast_task
                except asyncio.CancelledError:
                    pass
            
            # Tüm client'lara kapanma mesajı gönder
            if self.clients:
                shutdown_message = {
                    "type": "server_shutdown",
                    "message": "Sunucu kapatılıyor",
                    "timestamp": datetime.now().isoformat()
                }
                await self.broadcast_data(shutdown_message)
                
                # Client'ların bağlantısını kapat
                for client in self.clients.copy():
                    try:
                        await client.close()
                    except Exception:
                        pass
                
                self.clients.clear()
            
            # Sunucuyu kapat
            if self.server:
                self.server.close()
                await self.server.wait_closed()
            
            logger.info("Sunucu başarıyla kapatıldı")
            
        except Exception as e:
            logger.error(f"Sunucu kapatma hatası: {e}")

def setup_signal_handlers(server):
    """Sinyal işleyicilerini ayarla"""
    def signal_handler(signum, frame):
        logger.info(f"Sinyal alındı: {signum}")
        asyncio.create_task(server.shutdown())
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

async def main():
    """Ana fonksiyon"""
    server = None
    try:
        # Sunucuyu oluştur
        server = WebSocketServer()
        
        # Sinyal işleyicilerini ayarla
        setup_signal_handlers(server)
        
        # Sunucuyu başlat
        await server.start_server()
        
    except KeyboardInterrupt:
        logger.info("Kullanıcı tarafından durduruldu (Ctrl+C)")
    except Exception as e:
        logger.error(f"Ana program hatası: {e}")
        logger.error(traceback.format_exc())
    finally:
        if server:
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