# Hidrolink Python Server

Bu proje, hidrolojik sensör verilerini toplayan, loglayan ve Flutter mobil uygulamasına RESTful API üzerinden sunan Python tabanlı bir sunucudur. Gerçek zamanlı veri izleme, otomatik loglama, alarm yönetimi ve min/max değer hesaplama özelliklerini destekler.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [API Dokümantasyonu](#api-dokümantasyonu)
- [Veri Yapısı](#veri-yapısı)
- [Log Sistemi](#log-sistemi)
- [Alarm Sistemi](#alarm-sistemi)
- [Background Monitoring](#background-monitoring)
- [Konfigürasyon](#konfigürasyon)
- [Geliştirme](#geliştirme)
- [Sorun Giderme](#sorun-giderme)

## 🌟 Genel Bakış

Hidrolink Python Server, hidrolojik sensörlerden gelen verileri işleyen, saklayan, loglayan ve Flutter mobil uygulamasına RESTful API üzerinden sunan gelişmiş bir backend sistemidir. Sistem, gerçek zamanlı veri izleme, otomatik loglama, alarm yönetimi, min/max değer hesaplama ve veri analizi özelliklerini destekler.

### 🎯 Ana Amaçlar

- **Veri Toplama**: Sensörlerden gelen verileri toplama ve işleme
- **Otomatik Loglama**: Veri değişikliklerinde otomatik log kaydı
- **Veri Saklama**: JSON formatında veri saklama ve yönetme
- **API Sunumu**: Flutter uygulamasına RESTful API ile veri sunma
- **Alarm Yönetimi**: Gerçek zamanlı alarm sistemi
- **Background Monitoring**: Arka planda sürekli veri izleme
- **Min/Max Hesaplama**: Otomatik minimum ve maksimum değer hesaplama
- **Çoklu İstemci Desteği**: Aynı anda birden fazla cihazdan erişim

## ✨ Özellikler

### 🔄 RESTful API
- **Flask Tabanlı**: Modern ve hızlı web framework
- **CORS Desteği**: Tüm cihazlardan erişim
- **JSON Formatı**: Standart veri formatı
- **HTTP Metodları**: GET, POST, PUT, DELETE desteği
- **Background Monitoring**: Arka planda sürekli veri izleme

### 📊 Veri Yönetimi
- **JSON Dosya Sistemi**: Yapılandırılmış veri saklama
- **Otomatik Güncelleme**: Gerçek zamanlı veri güncelleme
- **Veri Doğrulama**: Gelen verilerin kontrolü
- **Hata Yönetimi**: Kapsamlı hata yakalama
- **Cache Sistemi**: Performans optimizasyonu

### 📈 Log Sistemi
- **Otomatik Loglama**: Veri değişikliklerinde otomatik kayıt
- **Tarih Filtreleme**: Gelişmiş tarih bazlı filtreleme
- **Min/Max Değerler**: Her log kaydında min/max değerler
- **Duplicate Prevention**: Tekrarlanan kayıtları önleme
- **Background Threading**: Arka planda sürekli izleme

### 🚨 Alarm Sistemi
- **Dinamik Alarmlar**: Kullanıcı tanımlı alarm kuralları
- **Renk Kodlaması**: Görsel alarm gösterimi
- **Alarm Bilgileri**: Açıklayıcı alarm mesajları
- **Gerçek Zamanlı**: Anında alarm tetikleme
- **Çoklu Alarm**: Her kanal için birden fazla alarm

### 🌐 Ağ Desteği
- **0.0.0.0 Host**: Tüm ağ arayüzlerinde dinleme
- **Port 8765**: Standart port kullanımı
- **WiFi Uyumlu**: Yerel ağ erişimi
- **Çoklu Cihaz**: Aynı anda birden fazla bağlantı
- **Threading**: Çoklu iş parçacığı desteği

## 🛠️ Kurulum

### Gereksinimler

- Python 3.8+
- Flask
- Flask-CORS
- İnternet bağlantısı

### Adım Adım Kurulum

1. **Python Kurulumu**
   ```bash
   # Python'un kurulu olduğunu kontrol edin
   python3 --version
   ```

2. **Proje Klasörüne Geçin**
   ```bash
   cd python_server
   ```

3. **Gerekli Paketleri Yükleyin**
   ```bash
   pip3 install flask flask-cors
   ```

4. **Sunucuyu Başlatın**
   ```bash
   python3 server.py
   ```

### Hızlı Başlangıç

```bash
# Tek komutla kurulum ve başlatma
cd python_server && python3 server.py
```

## 🚀 Kullanım

### Sunucu Başlatma

```bash
python3 server.py
```

**Başarılı Başlatma Mesajları:**
```
RESTful API sunucusu başlatılıyor: 0.0.0.0:8765
Sunucu tüm ağ arayüzlerinde dinliyor (0.0.0.0)
Aynı WiFi ağındaki tüm cihazlar erişebilir
Background monitoring otomatik olarak başlatılıyor...
Background monitoring loop başladı
Background monitoring thread başlatıldı
```

### Erişim URL'leri

- **Ana Sunucu**: `http://[IP_ADRESI]:8765`
- **API Base**: `http://[IP_ADRESI]:8765/api`
- **Health Check**: `http://[IP_ADRESI]:8765/api/health`

### IP Adresi Bulma

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig
```

## 📚 API Dokümantasyonu

### 🔍 Health Check
```http
GET /api/health
```

**Yanıt:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2025-08-11T11:55:56.176",
  "server": "Hidrolink RESTful API"
}
```

### 📊 Tüm Verileri Getir
```http
GET /api/data
```

**Yanıt:**
```json
{
  "success": true,
  "data": {
    "variable": {
      "channel": [...],
      "data": [...]
    },
    "alarm": {...}
  },
  "timestamp": "2025-08-11T11:55:56.279"
}
```

### 🔄 Değişken Verileri Getir (Min/Max Dahil)
```http
GET /api/data/variable
```

**Yanıt:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "channel": 1,
        "value": 12.0,
        "min_value": 11.3,
        "max_value": 12.0,
        "value_timestamp": 1640995200,
        "battery_percentage": 85,
        "signal_strength": 90,
        "value_type": 1
      }
    ]
  },
  "timestamp": "2025-08-11T11:55:56.279"
}
```

### 📈 Log Verilerini Getir (Tarih Filtreli)
```http
GET /api/logs/{channel_id}?start_date={start_date}&end_date={end_date}
```

**Parametreler:**
- `channel_id`: Kanal kimliği
- `start_date`: Başlangıç tarihi (ISO 8601 format)
- `end_date`: Bitiş tarihi (ISO 8601 format)

**Örnek:**
```http
GET /api/logs/1?start_date=2025-07-17T00:00:00.000&end_date=2025-07-19T00:00:00.000
```

**Yanıt:**
```json
{
  "success": true,
  "data": {
    "channel_id": 1,
    "channel_name": "TEST-KANAL-1-BASINÇ",
    "data": [
      {
        "id": 3,
        "timestamp": "2025-07-18T12:00:00Z",
        "value": 100,
        "min_value": 95,
        "max_value": 105
      },
      {
        "id": 4,
        "timestamp": "2025-07-17T15:30:00Z",
        "value": 85,
        "min_value": 80,
        "max_value": 90
      }
    ]
  },
  "timestamp": "2025-08-11T11:56:06.417"
}
```

### 💾 Log Verisi Kaydet
```http
POST /api/logs/{channel_id}
Content-Type: application/json

{
  "value": 25.5,
  "timestamp": "2025-08-11T11:56:06.417"
}
```

### 🚨 Alarm Verilerini Getir
```http
GET /api/data/alarm
```

### 💾 Alarm Verilerini Kaydet
```http
POST /api/data/alarm
Content-Type: application/json

{
  "parameter1": {
    "channel_id": 1,
    "dataPostFrequency": 1000,
    "alarminfo": "Sıcaklık kontrol alarmı",
    "alarms": [
      {
        "min_value": 5.0,
        "max_value": 15.0,
        "color": "#FF0000"
      }
    ]
  }
}
```

### 🔧 Kanal Alanını Güncelle
```http
PUT /api/channel/{channel_id}
Content-Type: application/json

{
  "field": "logInterval",
  "value": 5000
}
```

### 🔄 Monitoring Durumu
```http
GET /api/monitoring/status
```

**Yanıt:**
```json
{
  "success": true,
  "data": {
    "monitoring_active": true,
    "status": "running"
  },
  "timestamp": "2025-08-11T11:55:56.176"
}
```

### 🚀 Monitoring Başlat/Durdur
```http
POST /api/monitoring/start
POST /api/monitoring/stop
```

### 📊 Veri Değişikliklerini Kontrol Et
```http
GET /api/data/check-changes
```

### 🔄 Otomatik Log Kaydetme
```http
POST /api/logs/auto-save
```

### ℹ️ Sunucu Bilgileri
```http
GET /api/info
```

## 📁 Veri Yapısı

### Klasör Yapısı
```
python_server/
├── server.py              # Ana sunucu dosyası
├── json_reader.py         # JSON veri yöneticisi
├── jsons/                 # JSON veri dosyaları
│   ├── variable/          # Değişken veriler
│   │   ├── channel.json   # Kanal tanımları
│   │   └── data.json      # Sensör verileri (min/max dahil)
│   ├── alarm/             # Alarm verileri
│   │   └── alarm.json     # Alarm tanımları
│   └── logsfile/          # Log verileri
│       └── logs.json      # Tarih bazlı log kayıtları
└── README.md              # Bu dosya
```

### JSON Dosya Formatları

#### Channel.json
```json
{
  "channel": [
    {
      "id": 1,
      "name": "TEST-KANAL-1-BASINÇ",
      "description": "Basınç ölçümü",
      "channel_category": 1,
      "channel_sub_category": 1,
      "channel_parameter": 1,
      "measurement_unit": 1,
      "log_interval": 1000,
      "offset": 0.0
    }
  ]
}
```

#### Data.json (Min/Max Dahil)
```json
{
  "data": [
    {
      "channel": 1,
      "value": 12.0,
      "min_value": 11.3,
      "max_value": 12.0,
      "value_timestamp": 1640995200,
      "battery_percentage": 85,
      "signal_strength": 90,
      "value_type": 1
    }
  ]
}
```

#### Alarm.json
```json
{
  "parameter1": {
    "channel_id": 1,
    "dataPostFrequency": 1000,
    "alarminfo": "Basınç kontrol alarmı",
    "alarms": [
      {
        "min_value": 5.0,
        "max_value": 15.0,
        "color": "#FF0000"
      }
    ]
  }
}
```

#### Logs.json
```json
{
  "logs": {
    "channel_1": {
      "channel_id": 1,
      "channel_name": "TEST-KANAL-1-BASINÇ",
      "data": [
        {
          "id": 1,
          "timestamp": "2025-08-10T23:35:17Z",
          "value": 12.0,
          "min_value": 11.3,
          "max_value": 12.0
        },
        {
          "id": 3,
          "timestamp": "2025-07-18T12:00:00Z",
          "value": 100.0,
          "min_value": 95.0,
          "max_value": 105.0
        }
      ]
    }
  }
}
```

## 📈 Log Sistemi

### Otomatik Loglama
- **Background Monitoring**: Arka planda sürekli veri izleme
- **Veri Değişiklikleri**: `data.json` değişikliklerinde otomatik kayıt
- **Duplicate Prevention**: Tekrarlanan kayıtları önleme
- **Min/Max Hesaplama**: Her kayıt için min/max değerler

### Tarih Filtreleme
- **Gelişmiş Filtreleme**: ISO 8601 formatında tarih desteği
- **Timezone Handling**: UTC timezone desteği
- **Range Queries**: Başlangıç ve bitiş tarihi ile filtreleme
- **Performance**: Optimize edilmiş tarih karşılaştırma

### Log Veri Yapısı
```python
class LogEntry:
    id: int                    # Benzersiz kimlik
    timestamp: str             # ISO 8601 format
    value: float               # Sensör değeri
    min_value: float           # Minimum değer
    max_value: float           # Maksimum değer
```

### Background Monitoring
```python
# Otomatik başlatma
def start_background_monitoring(self):
    if not self.monitoring_active:
        self.monitoring_active = True
        self.monitoring_thread = threading.Thread(target=self._monitoring_loop)
        self.monitoring_thread.daemon = True
        self.monitoring_thread.start()

# Monitoring loop
def _monitoring_loop(self):
    while self.monitoring_active:
        try:
            self.json_reader.check_data_changes()
            time.sleep(0.1)  # 100ms aralık
        except Exception as e:
            logger.error(f"Monitoring loop hatası: {e}")
```

## 🚨 Alarm Sistemi

### Alarm Yapısı
- **channel_id**: Kanal kimliği
- **dataPostFrequency**: Veri gönderme sıklığı (ms)
- **alarminfo**: Alarm açıklaması
- **alarms**: Alarm listesi

### Alarm Özellikleri
- **min_value**: Minimum değer
- **max_value**: Maksimum değer
- **color**: Renk kodu (hex format)
- **Çoklu Alarm**: Her kanal için birden fazla alarm

### Renk Kodları
- `#FF0000` - Kırmızı
- `#00FF00` - Yeşil
- `#0000FF` - Mavi
- `#FFFF00` - Sarı
- `#FF00FF` - Magenta
- `#00FFFF` - Cyan
- `#FFA500` - Turuncu
- `#800080` - Mor
- `#008000` - Koyu Yeşil
- `#FFC0CB` - Pembe

## 🔄 Background Monitoring

### Otomatik Başlatma
- **Server Başlangıcında**: Monitoring otomatik olarak başlar
- **Threading**: Arka planda sürekli çalışır
- **Veri İzleme**: `data.json` değişikliklerini sürekli kontrol eder
- **Log Kaydetme**: Değişikliklerde otomatik log kaydı

### Monitoring Endpoint'leri
```http
GET /api/monitoring/status      # Monitoring durumu
POST /api/monitoring/start      # Monitoring başlat
POST /api/monitoring/stop       # Monitoring durdur
```

### Performance Optimizasyonu
- **100ms Aralık**: Veri değişikliklerini hızlı tespit
- **Cache System**: Gereksiz dosya okumalarını önleme
- **Threading**: Ana thread'i bloklamama
- **Error Handling**: Hata durumlarında graceful recovery

## ⚙️ Konfigürasyon

### Sunucu Ayarları
```python
# server.py içinde
host = '0.0.0.0'  # Tüm ağ arayüzleri
port = 8765       # Port numarası
debug = False     # Debug modu
threaded = True   # Çoklu iş parçacığı
```

### CORS Ayarları
```python
CORS(app, resources={
    r"/api/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"],
        "expose_headers": ["Content-Type", "Authorization"]
    }
})
```

### Monitoring Ayarları
```python
# json_reader.py içinde
self.check_interval = 0.1  # 100ms kontrol aralığı

# server.py içinde
def start_background_monitoring(self):
    # Otomatik monitoring başlatma
```

## 🔧 Geliştirme

### Yeni Endpoint Ekleme
```python
@app.route('/api/yeni-endpoint', methods=['GET'])
def yeni_endpoint():
    try:
        # İşlemler
        return jsonify({
            "success": True,
            "data": veri
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
```

### Logging
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
```

### Hata Yönetimi
```python
try:
    # İşlemler
    pass
except Exception as e:
    logger.error(f"Hata: {e}")
    return jsonify({"success": False, "error": str(e)}), 500
```

### Threading
```python
import threading
import time

def background_task():
    while True:
        try:
            # Arka plan işlemleri
            time.sleep(0.1)
        except Exception as e:
            logger.error(f"Background task hatası: {e}")

# Thread başlatma
thread = threading.Thread(target=background_task)
thread.daemon = True
thread.start()
```

## 🐛 Sorun Giderme

### Yaygın Sorunlar

#### 1. Port Kullanımda
```bash
# Portu kontrol edin
lsof -i :8765

# Portu temizleyin
lsof -ti:8765 | xargs kill -9
```

#### 2. Bağlantı Hatası
```bash
# Sunucunun çalıştığını kontrol edin
curl http://localhost:8765/api/health

# IP adresini kontrol edin
ifconfig | grep "inet "
```

#### 3. CORS Hatası
- Sunucunun `0.0.0.0` host'ta çalıştığından emin olun
- CORS ayarlarının doğru olduğunu kontrol edin

#### 4. JSON Dosya Hatası
```bash
# JSON dosyalarının varlığını kontrol edin
ls -la jsons/
ls -la jsons/variable/
ls -la jsons/alarm/
ls -la jsons/logsfile/
```

#### 5. Log Verisi Görünmüyor
- Background monitoring'in çalıştığını kontrol edin
- `logs.json` dosyasında veri olduğunu kontrol edin
- Tarih filtreleme parametrelerini kontrol edin

#### 6. Min/Max Değerler Hesaplanmıyor
- `logs.json` dosyasında yeterli veri olduğunu kontrol edin
- Background monitoring'in aktif olduğunu kontrol edin
- API endpoint'lerinin doğru çalıştığını kontrol edin

### Debug Modu
```python
# server.py'de debug modunu açın
self.app.run(
    host=host,
    port=port,
    debug=True,  # Debug modu
    threaded=True
)
```

### Log Seviyeleri
```python
# Daha detaylı loglar için
logging.basicConfig(level=logging.DEBUG)
```

### Monitoring Debug
```python
# Monitoring durumunu kontrol edin
curl http://localhost:8765/api/monitoring/status

# Veri değişikliklerini kontrol edin
curl http://localhost:8765/api/data/check-changes
```

## 📞 Destek

### İletişim
- **Geliştirici**: Hidrolink AKIM ELEKTRONIK
- **Versiyon**: 1.0.0
- **Son Güncelleme**: 2025-08-11

### Teknik Detaylar
- **Framework**: Flask
- **Dil**: Python 3.8+
- **API**: RESTful HTTP
- **Veri Formatı**: JSON
- **Threading**: Çoklu iş parçacığı desteği
- **Background Monitoring**: Otomatik veri izleme

### Gereksinimler
- **Python**: 3.8+
- **Flask**: Web framework
- **Flask-CORS**: CORS desteği
- **Threading**: Arka plan işlemleri
- **JSON**: Veri formatı

---

**Not**: Bu sunucu, Hidrolink Flutter uygulaması ile birlikte çalışmak üzere tasarlanmıştır. Tüm özellikler için Python server'ın çalışır durumda olması gereklidir.