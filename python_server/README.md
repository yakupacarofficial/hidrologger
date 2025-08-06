# Hidrologger Python Server

Bu proje, hidrolojik sensör verilerini toplayan ve Flutter mobil uygulamasına RESTful API üzerinden sunan Python tabanlı bir sunucudur.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [API Dokümantasyonu](#api-dokümantasyonu)
- [Veri Yapısı](#veri-yapısı)
- [Alarm Sistemi](#alarm-sistemi)
- [Konfigürasyon](#konfigürasyon)
- [Geliştirme](#geliştirme)
- [Sorun Giderme](#sorun-giderme)

## 🌟 Genel Bakış

Hidrologger Python Server, hidrolojik sensörlerden gelen verileri işleyen, saklayan ve Flutter mobil uygulamasına RESTful API üzerinden sunan bir backend sistemidir. Sistem, gerçek zamanlı veri izleme, alarm yönetimi ve veri analizi özelliklerini destekler.

### 🎯 Ana Amaçlar

- **Veri Toplama**: Sensörlerden gelen verileri toplama ve işleme
- **Veri Saklama**: JSON formatında veri saklama ve yönetme
- **API Sunumu**: Flutter uygulamasına RESTful API ile veri sunma
- **Alarm Yönetimi**: Gerçek zamanlı alarm sistemi
- **Çoklu İstemci Desteği**: Aynı anda birden fazla cihazdan erişim

## ✨ Özellikler

### 🔄 RESTful API
- **Flask Tabanlı**: Modern ve hızlı web framework
- **CORS Desteği**: Tüm cihazlardan erişim
- **JSON Formatı**: Standart veri formatı
- **HTTP Metodları**: GET, POST, PUT, DELETE desteği

### 📊 Veri Yönetimi
- **JSON Dosya Sistemi**: Yapılandırılmış veri saklama
- **Otomatik Güncelleme**: Gerçek zamanlı veri güncelleme
- **Veri Doğrulama**: Gelen verilerin kontrolü
- **Hata Yönetimi**: Kapsamlı hata yakalama

### 🚨 Alarm Sistemi
- **Dinamik Alarmlar**: Kullanıcı tanımlı alarm kuralları
- **Renk Kodlaması**: Görsel alarm gösterimi
- **Alarm Bilgileri**: Açıklayıcı alarm mesajları
- **Gerçek Zamanlı**: Anında alarm tetikleme

### 🌐 Ağ Desteği
- **0.0.0.0 Host**: Tüm ağ arayüzlerinde dinleme
- **Port 8765**: Standart port kullanımı
- **WiFi Uyumlu**: Yerel ağ erişimi
- **Çoklu Cihaz**: Aynı anda birden fazla bağlantı

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
  "timestamp": "2025-08-05T17:32:10.092452",
  "server": "Hidrologger RESTful API"
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
  "timestamp": "2025-08-05T17:32:10.092452"
}
```

### 🔄 Değişken Verileri Getir
```http
GET /api/data/variable
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
│   │   └── data.json      # Sensör verileri
│   └── alarm/             # Alarm verileri
│       └── alarm.json     # Alarm tanımları
└── README.md              # Bu dosya
```

### JSON Dosya Formatları

#### Channel.json
```json
{
  "channel": [
    {
      "id": 1,
      "name": "Sıcaklık Sensörü",
      "description": "Ortam sıcaklığı ölçümü",
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

#### Data.json
```json
{
  "data": [
    {
      "channel": 1,
      "value": 25.5,
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
```

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

## 📞 Destek

### İletişim
- **Geliştirici**: Hidrologger AKIM ELEKTRONIK
- **Versiyon**: 1.0.0
- **Son Güncelleme**: 2025-08-05

---

**Not**: Bu sunucu, Hidrologger Flutter uygulaması ile birlikte çalışmak üzere tasarlanmıştır.