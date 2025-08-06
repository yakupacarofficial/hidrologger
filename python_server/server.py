import asyncio
import json
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from json_reader import JSONReader

# Logging ayarları
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class RESTfulServer:
    def __init__(self):
        self.json_reader = JSONReader()
        self.app = Flask(__name__)
        # CORS ayarları - tüm cihazlardan erişime izin ver
        CORS(self.app, resources={
            r"/api/*": {
                "origins": ["*"],
                "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
                "allow_headers": ["Content-Type", "Authorization", "Accept"],
                "expose_headers": ["Content-Type", "Authorization"]
            }
        })
        
        # API endpoint'lerini tanımla
        self.setup_routes()
    
    def setup_routes(self):
        """API endpoint'lerini tanımla"""
        
        @self.app.route('/api/data', methods=['GET'])
        def get_all_data():
            """Tüm verileri getir"""
            try:
                logger.info("Tüm veriler istendi")
                data = self.json_reader.read_all_data()
                return jsonify({
                    "success": True,
                    "data": data,
                    "timestamp": datetime.now().isoformat()
                })
            except Exception as e:
                logger.error(f"Veri getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/data/variable', methods=['GET'])
        def get_variable_data():
            """Sadece değişken verileri getir"""
            try:
                logger.info("Değişken veriler istendi")
                data = self.json_reader.read_all_data()
                return jsonify({
                    "success": True,
                    "data": data.get('variable', {}),
                    "timestamp": datetime.now().isoformat()
                })
            except Exception as e:
                logger.error(f"Değişken veri getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/data/alarm', methods=['GET'])
        def get_alarm_data():
            """Alarm verilerini getir"""
            try:
                logger.info("Alarm verileri istendi")
                alarm_data = self.json_reader.get_alarm_data()
                if alarm_data is not None:
                    return jsonify({
                        "success": True,
                        "data": alarm_data,
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Alarm verileri bulunamadı"
                    }), 404
            except Exception as e:
                logger.error(f"Alarm veri getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/data/alarm', methods=['POST'])
        def save_alarm_data():
            """Alarm verilerini kaydet"""
            try:
                logger.info("Alarm kaydetme istendi")
                alarm_data = request.get_json()
                
                if alarm_data is None:
                    return jsonify({
                        "success": False,
                        "error": "Geçersiz JSON verisi"
                    }), 400
                
                success = self.json_reader.save_alarm_data(alarm_data)
                if success:
                    logger.info("Alarm verileri başarıyla kaydedildi")
                    return jsonify({
                        "success": True,
                        "message": "Alarm verileri başarıyla kaydedildi",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Alarm kaydetme başarısız"
                    }), 500
            except Exception as e:
                logger.error(f"Alarm kaydetme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/channel', methods=['POST'])
        def create_channel():
            """Yeni kanal oluştur"""
            try:
                logger.info("Yeni kanal oluşturma istendi")
                channel_data = request.get_json()
                
                if channel_data is None:
                    return jsonify({
                        "success": False,
                        "error": "Geçersiz JSON verisi"
                    }), 400
                
                success = self.json_reader.create_channel(channel_data)
                if success:
                    logger.info("Yeni kanal başarıyla oluşturuldu")
                    return jsonify({
                        "success": True,
                        "message": "Yeni kanal başarıyla oluşturuldu",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Kanal oluşturma başarısız"
                    }), 500
            except Exception as e:
                logger.error(f"Kanal oluşturma hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/channel/<int:channel_id>', methods=['PUT'])
        def update_channel_field(channel_id):
            """Kanal alanını güncelle"""
            try:
                logger.info(f"Kanal {channel_id} güncelleme istendi")
                data = request.get_json()
                
                if not data or 'field' not in data or 'value' not in data:
                    return jsonify({
                        "success": False,
                        "error": "field ve value parametreleri gerekli"
                    }), 400
                
                field = data['field']
                value = data['value']
                
                success = self.json_reader.update_channel_field(channel_id, field, value)
                if success:
                    logger.info(f"Kanal {channel_id} {field} alanı güncellendi")
                    return jsonify({
                        "success": True,
                        "message": f"Kanal {channel_id} {field} alanı güncellendi",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Kanal güncelleme başarısız"
                    }), 500
            except Exception as e:
                logger.error(f"Kanal güncelleme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/channel/<int:channel_id>', methods=['DELETE'])
        def delete_channel(channel_id):
            """Kanalı sil"""
            try:
                logger.info(f"Kanal {channel_id} silme istendi")
                
                success = self.json_reader.delete_channel(channel_id)
                if success:
                    logger.info(f"Kanal {channel_id} başarıyla silindi")
                    return jsonify({
                        "success": True,
                        "message": f"Kanal {channel_id} başarıyla silindi",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Kanal silme başarısız"
                    }), 500
            except Exception as e:
                logger.error(f"Kanal silme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/health', methods=['GET'])
        def health_check():
            """Sağlık kontrolü"""
            return jsonify({
                "success": True,
                "status": "healthy",
                "timestamp": datetime.now().isoformat(),
                "server": "Hidrologger RESTful API"
            })
        
        @self.app.route('/api/info', methods=['GET'])
        def get_server_info():
            """Sunucu bilgilerini getir"""
            try:
                data_summary = self.json_reader.get_data_summary()
                return jsonify({
                    "success": True,
                    "server_info": {
                        "name": "Hidrologger RESTful API",
                        "version": "1.0.0",
                        "timestamp": datetime.now().isoformat()
                    },
                    "data_summary": data_summary
                })
            except Exception as e:
                logger.error(f"Sunucu bilgi getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
    
    def start_server(self, host='0.0.0.0', port=8765):
        """RESTful API sunucusunu başlat - tüm ağ arayüzlerinde dinle"""
        logger.info(f"RESTful API sunucusu başlatılıyor: {host}:{port}")
        logger.info("Sunucu tüm ağ arayüzlerinde dinliyor (0.0.0.0)")
        logger.info("Aynı WiFi ağındaki tüm cihazlar erişebilir")
        
        try:
            self.app.run(
                host=host,
                port=port,
                debug=False,
                threaded=True,
                use_reloader=False
            )
        except Exception as e:
            logger.error(f"Sunucu başlatma hatası: {e}")
            raise

def main():
    """Ana fonksiyon"""
    try:
        server = RESTfulServer()
        server.start_server()
    except KeyboardInterrupt:
        logger.info("Sunucu kullanıcı tarafından durduruldu")
    except Exception as e:
        logger.error(f"Sunucu hatası: {e}")

if __name__ == "__main__":
    main()