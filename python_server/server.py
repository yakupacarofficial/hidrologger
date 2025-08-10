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
            """Sadece değişken verileri getir ve min/max değerleri hesapla"""
            try:
                logger.info("Değişken veriler istendi")
                data = self.json_reader.read_all_data()
                variable_data = data.get('variable', {})
                
                # Min/max değerleri hesapla ve güncelle
                if variable_data and 'data' in variable_data and variable_data['data']:
                    logger.info(f"Min/max hesaplama başlıyor. Data: {variable_data['data']}")
                    updated_data = []
                    for item in variable_data['data']:
                        channel_id = item.get('channel')
                        current_value = item.get('value', 0)
                        logger.info(f"Kanal {channel_id} için işleniyor, current_value: {current_value}")
                        
                        # Logs.json'dan min/max değerleri al
                        logs_data = self.json_reader.get_log_data(channel_id)
                        logger.info(f"Kanal {channel_id} için logs_data: {logs_data}")
                        if logs_data and 'data' in logs_data and logs_data['data']:
                            values = [log.get('value', 0) for log in logs_data['data']]
                            logger.info(f"Kanal {channel_id} için values: {values}")
                            if values:
                                min_value = min(values)
                                max_value = max(values)
                                logger.info(f"Kanal {channel_id} için min: {min_value}, max: {max_value}")
                            else:
                                min_value = current_value
                                max_value = current_value
                        else:
                            min_value = current_value
                            max_value = current_value
                        
                        # Güncellenmiş veriyi ekle
                        updated_item = item.copy()
                        updated_item['min_value'] = min_value
                        updated_item['max_value'] = max_value
                        updated_data.append(updated_item)
                        logger.info(f"Güncellenmiş item: {updated_item}")
                    
                    # Güncellenmiş veriyi data.json'a kaydet
                    variable_data['data'] = updated_data
                    logger.info(f"Kaydedilecek veri: {variable_data}")
                    self.json_reader.save_variable_data(variable_data)
                
                return jsonify({
                    "success": True,
                    "data": variable_data,
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
                return jsonify({
                    "success": True,
                    "server_info": {
                        "name": "Hidrolink RESTful Server",
                        "version": "1.0.0",
                        "status": "running",
                        "timestamp": datetime.now().isoformat()
                    }
                })
            except Exception as e:
                logger.error(f"Sunucu bilgisi getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/logs/<int:channel_id>', methods=['GET'])
        def get_logs(channel_id):
            """Belirli kanal için log verilerini getir"""
            try:
                # Query parametrelerini al
                start_date = request.args.get('start_date')
                end_date = request.args.get('end_date')
                
                logger.info(f"Kanal {channel_id} için log verileri istendi - Başlangıç: {start_date}, Bitiş: {end_date}")
                
                log_data = self.json_reader.get_log_data(channel_id, start_date, end_date)
                
                if log_data is not None:
                    logger.info(f"Kanal {channel_id} için {len(log_data.get('data', []))} log kaydı döndürüldü")
                    return jsonify({
                        "success": True,
                        "data": log_data,
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    logger.warning(f"Kanal {channel_id} için log verisi bulunamadı")
                    return jsonify({
                        "success": False,
                        "error": f"Kanal {channel_id} için log verisi bulunamadı"
                    }), 404
                    
            except Exception as e:
                logger.error(f"Log veri getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/logs/<int:channel_id>', methods=['POST'])
        def save_log(channel_id):
            """Belirli kanal için log verisi kaydet"""
            try:
                logger.info(f"Kanal {channel_id} için log verisi kaydetme istendi")
                
                data = request.get_json()
                if not data:
                    return jsonify({
                        "success": False,
                        "error": "Veri bulunamadı"
                    }), 400
                
                value = data.get('value')
                timestamp = data.get('timestamp')
                
                if value is None:
                    return jsonify({
                        "success": False,
                        "error": "Value değeri gerekli"
                    }), 400
                
                success = self.json_reader.save_log_data(channel_id, value, timestamp)
                
                if success:
                    return jsonify({
                        "success": True,
                        "message": f"Kanal {channel_id} için log verisi kaydedildi",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Log verisi kaydedilemedi"
                    }), 500
                    
            except Exception as e:
                logger.error(f"Log veri kaydetme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/alarms/check', methods=['GET'])
        def check_alarms():
            """Alarm durumlarını kontrol et ve log verilerini kaydet"""
            try:
                logger.info("Alarm kontrolü istendi")
                active_alarms = self.json_reader.check_alarms()
                
                return jsonify({
                    "success": True,
                    "data": active_alarms,
                    "count": len(active_alarms),
                    "timestamp": datetime.now().isoformat()
                })
                
            except Exception as e:
                logger.error(f"Alarm kontrol hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/alarms/active', methods=['GET'])
        def get_active_alarms():
            """Aktif alarmları getir"""
            try:
                logger.info("Aktif alarmlar istendi")
                active_alarms = self.json_reader.check_alarms()
                
                return jsonify({
                    "success": True,
                    "data": active_alarms,
                    "count": len(active_alarms),
                    "timestamp": datetime.now().isoformat()
                })
                
            except Exception as e:
                logger.error(f"Aktif alarm getirme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/alarms/clear', methods=['POST'])
        def clear_alarms():
            """Tüm alarmları temizle"""
            try:
                logger.info("Alarm temizleme istendi")
                # Bu endpoint şimdilik sadece başarı mesajı döndürüyor
                # Gerçek alarm temizleme mantığı daha sonra eklenebilir
                
                return jsonify({
                    "success": True,
                    "message": "Alarmlar temizlendi",
                    "timestamp": datetime.now().isoformat()
                })
                
            except Exception as e:
                logger.error(f"Alarm temizleme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500
        
        @self.app.route('/api/logs/auto-save', methods=['POST'])
        def auto_save_logs():
            """Data.json dosyasındaki verileri otomatik olarak log verilerine kaydet"""
            try:
                logger.info("Otomatik log kaydetme istendi")
                success = self.json_reader.auto_save_logs_from_data()
                
                if success:
                    return jsonify({
                        "success": True,
                        "message": "Log verileri otomatik olarak kaydedildi",
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    return jsonify({
                        "success": False,
                        "error": "Log verileri kaydedilemedi"
                    }), 500
                    
            except Exception as e:
                logger.error(f"Otomatik log kaydetme hatası: {e}")
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 500

        @self.app.route('/api/data/check-changes', methods=['GET'])
        def check_data_changes():
            """Data.json dosyasındaki değişiklikleri kontrol et ve log verilerini otomatik olarak kaydet"""
            try:
                logger.info("Data değişiklik kontrolü istendi")
                changes_detected = self.json_reader.check_data_changes()
                
                return jsonify({
                    "success": True,
                    "changes_detected": changes_detected,
                    "message": "Data değişiklik kontrolü tamamlandı",
                    "timestamp": datetime.now().isoformat()
                })
                
            except Exception as e:
                logger.error(f"Data değişiklik kontrolü hatası: {e}")
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