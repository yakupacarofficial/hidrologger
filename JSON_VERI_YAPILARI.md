# HIDROLOGGER - Server.py ↔ Flutter JSON Veri Alışverişi

## 📡 SERVER.PY → FLUTTER (GET İstekleri)

### 1. Tüm Verileri Getir - `/api/data`
**Server Response:**
```json
{
  "success": true,
  "data": {
    "variable": {
      "data": [
        {
          "id": 1,
          "channel": 1,
          "value_type": 1,
          "value_timestamp": 1754742970,
          "value": 555,
          "min_value": 333,
          "max_value": 444,
          "battery_percentage": 100,
          "signal_strength": 100
        }
      ]
    },
    "alarm": {
      "parameter1": {
        "channel_id": 1,
        "alarminfo": "Kanal 1 alarm ayarları",
        "alarms": [
          {
            "min_value": 20,
            "max_value": 24,
            "color": "#FF0000",
            "data_post_frequency": 1000
          }
        ]
      }
    }
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 2. Sadece Değişken Verileri - `/api/data/variable`
**Server Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "channel": 1,
        "value_type": 1,
        "value_timestamp": 1754742970,
        "value": 555,
        "min_value": 333,
        "max_value": 444,
        "battery_percentage": 100,
        "signal_strength": 100
      }
    ]
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 3. Alarm Verilerini Getir - `/api/data/alarm`
**Server Response:**
```json
{
  "success": true,
  "data": {
    "parameter1": {
      "channel_id": 1,
      "alarminfo": "Kanal 1 alarm ayarları",
      "alarms": [
        {
          "min_value": 20,
          "max_value": 24,
          "color": "#FF0000",
          "data_post_frequency": 1000
        }
      ]
    }
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 4. Log Verilerini Getir - `/api/logs/{channel_id}`
**Server Response:**
```json
{
  "success": true,
  "data": {
    "channel_id": 1,
    "channel_name": "TEST1",
    "data": [
      {
        "id": 1,
        "timestamp": "2024-01-15T10:00:00Z",
        "value": 25.3
      }
    ]
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 5. Alarm Durumlarını Kontrol Et - `/api/alarms/check`
**Server Response:**
```json
{
  "success": true,
  "data": [
    {
      "channel_id": 1,
      "channel_name": "TEST1",
      "alarm_type": "min_value",
      "current_value": 15.5,
      "threshold": 20,
      "timestamp": "2024-01-15T10:00:00Z"
    }
  ],
  "count": 1,
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 6. Aktif Alarmları Getir - `/api/alarms/active`
**Server Response:**
```json
{
  "success": true,
  "data": [
    {
      "channel_id": 1,
      "channel_name": "TEST1",
      "alarm_type": "max_value",
      "current_value": 26.8,
      "threshold": 24,
      "timestamp": "2024-01-15T10:00:00Z"
    }
  ],
  "count": 1,
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 7. Data Değişiklik Kontrolü - `/api/data/check-changes`
**Server Response:**
```json
{
  "success": true,
  "changes_detected": true,
  "message": "Data değişiklik kontrolü tamamlandı",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 8. Sağlık Kontrolü - `/api/health`
**Server Response:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2024-01-15T10:00:00Z",
  "server": "Hidrologger RESTful API"
}
```

### 9. Sunucu Bilgileri - `/api/info`
**Server Response:**
```json
{
  "success": true,
  "server_info": {
    "name": "Hidrolink RESTful Server",
    "version": "1.0.0",
    "status": "running",
    "timestamp": "2024-01-15T10:00:00Z"
  }
}
```

---

## 📤 FLUTTER → SERVER.PY (POST/PUT/DELETE İstekleri)

### 1. Yeni Kanal Oluştur - `/api/channel`
**Flutter Request:**
```json
{
  "id": 1,
  "name": "TEST1",
  "category": "Su Kalitesi",
  "sub_category": "Su Sıcaklığı",
  "parameter": "Sıcaklık",
  "unit": "°C",
  "offset": -2.5,
  "alarm_settings": {
    "alarm1": {
      "min": 20,
      "max": 24,
      "ms": 1000
    }
  }
}
```

**Server Response:**
```json
{
  "success": true,
  "message": "Yeni kanal başarıyla oluşturuldu",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 2. Alarm Verilerini Kaydet - `/api/data/alarm`
**Flutter Request:**
```json
{
  "parameter1": {
    "channel_id": 1,
    "alarminfo": "Kanal 1 alarm ayarları",
    "alarms": [
      {
        "min_value": 20,
        "max_value": 24,
        "color": "#FF0000",
        "data_post_frequency": 1000
      }
    ]
  }
}
```

**Server Response:**
```json
{
  "success": true,
  "message": "Alarm verileri başarıyla kaydedildi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 3. Log Verisi Kaydet - `/api/logs/{channel_id}`
**Flutter Request:**
```json
{
  "value": 25.3,
  "timestamp": "2024-01-15T10:00:00Z"
}
```

**Server Response:**
```json
{
  "success": true,
  "message": "Kanal 1 için log verisi kaydedildi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 4. Kanal Alanını Güncelle - `/api/channel/{channel_id}`
**Flutter Request:**
```json
{
  "field": "name",
  "value": "YENI_ISIM"
}
```

**Server Response:**
```json
{
  "success": true,
  "message": "Kanal 1 name alanı güncellendi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 5. Kanalı Sil - `/api/channel/{channel_id}`
**Flutter Request:** (Body yok, DELETE method)

**Server Response:**
```json
{
  "success": true,
  "message": "Kanal 1 başarıyla silindi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 6. Otomatik Log Kaydetme - `/api/logs/auto-save`
**Flutter Request:** (Body yok, POST method)

**Server Response:**
```json
{
  "success": true,
  "message": "Log verileri otomatik olarak kaydedildi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### 7. Alarm Temizleme - `/api/alarms/clear`
**Flutter Request:** (Body yok, POST method)

**Server Response:**
```json
{
  "success": true,
  "message": "Alarmlar temizlendi",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

---

## 🔄 VERİ AKIŞI ÖZETİ

### **GET İstekleri (Server → Flutter):**
- **Dashboard verileri**: `/api/data` - Tüm kanal ve alarm bilgileri
- **Gerçek zamanlı veriler**: `/api/data/variable` - Sensör değerleri
- **Alarm durumları**: `/api/alarms/check` - Aktif alarmlar
- **Log geçmişi**: `/api/logs/{channel_id}` - Tarihsel veriler
- **Sistem durumu**: `/api/health`, `/api/info` - Sunucu bilgileri

### **POST İstekleri (Flutter → Server):**
- **Kanal oluşturma**: Sensör sihirbazından yeni kanal
- **Alarm ayarları**: Kanal bazında alarm kuralları
- **Log kaydetme**: Manuel log verisi ekleme
- **Otomatik işlemler**: Log ve alarm kontrolleri

### **PUT İstekleri (Flutter → Server):**
- **Kanal güncelleme**: Mevcut kanal bilgilerini değiştirme

### **DELETE İstekleri (Flutter → Server):**
- **Kanal silme**: Mevcut kanalı kaldırma

---

## 📊 JSON VERİ YAPILARI

### **Variable Data (Sensör Verileri):**
```json
{
  "id": 1,
  "channel": 1,
  "value_type": 1,
  "value_timestamp": 1754742970,
  "value": 555.0,
  "min_value": 333.0,
  "max_value": 444.0,
  "battery_percentage": 100,
  "signal_strength": 100
}
```

### **Alarm Data (Alarm Kuralları):**
```json
{
  "parameter1": {
    "channel_id": 1,
    "alarminfo": "Kanal 1 alarm ayarları",
    "alarms": [
      {
        "min_value": 20.0,
        "max_value": 24.0,
        "color": "#FF0000",
        "data_post_frequency": 1000
      }
    ]
  }
}
```

### **Log Data (Tarihsel Veriler):**
```json
{
  "channel_id": 1,
  "channel_name": "TEST1",
  "data": [
    {
      "id": 1,
      "timestamp": "2024-01-15T10:00:00Z",
      "value": 25.3
    }
  ]
}
```

---

## 🌐 API ENDPOINT ÖZETİ

| Method | Endpoint | Açıklama | Request Body | Response |
|--------|----------|----------|--------------|----------|
| GET | `/api/data` | Tüm verileri getir | - | ChannelData + Alarms |
| GET | `/api/data/variable` | Sensör verilerini getir | - | Variable Data Array |
| GET | `/api/data/alarm` | Alarm kurallarını getir | - | Alarm Rules |
| GET | `/api/logs/{id}` | Log verilerini getir | Query: start_date, end_date | Log Data |
| GET | `/api/alarms/check` | Alarm durumlarını kontrol et | - | Active Alarms |
| GET | `/api/alarms/active` | Aktif alarmları getir | - | Active Alarms |
| GET | `/api/health` | Sunucu sağlık kontrolü | - | Health Status |
| GET | `/api/info` | Sunucu bilgileri | - | Server Info |
| POST | `/api/channel` | Yeni kanal oluştur | Channel Data | Success Message |
| POST | `/api/data/alarm` | Alarm kurallarını kaydet | Alarm Rules | Success Message |
| POST | `/api/logs/{id}` | Log verisi kaydet | Value + Timestamp | Success Message |
| POST | `/api/logs/auto-save` | Otomatik log kaydetme | - | Success Message |
| POST | `/api/alarms/clear` | Alarmları temizle | - | Success Message |
| PUT | `/api/channel/{id}` | Kanal alanını güncelle | Field + Value | Success Message |
| DELETE | `/api/channel/{id}` | Kanalı sil | - | Success Message |

---

## 📱 FLUTTER TARAFINDA KULLANIM

### **RESTfulService Sınıfı:**
```dart
class RESTfulService {
  final String _baseUrl = 'http://$ip:$port/api';
  
  // GET istekleri
  Future<ChannelData?> fetchAllData()
  Future<Map<String, dynamic>?> fetchVariableData()
  Future<Map<String, dynamic>?> fetchAlarmData()
  Future<Map<String, dynamic>?> fetchLogData(int channelId, {String? startDate, String? endDate})
  
  // POST istekleri
  Future<bool> createChannel(Map<String, dynamic> channelData)
  Future<bool> saveAlarmData(Map<String, dynamic> alarmData)
  Future<bool> saveLogData(int channelId, double value, {String? timestamp})
  
  // PUT istekleri
  Future<bool> updateChannelField(int channelId, String field, dynamic value)
  
  // DELETE istekleri
  Future<bool> deleteChannel(int channelId)
}
```

### **Veri Akışı:**
1. **Dashboard**: `fetchAllData()` ile tüm veriler çekilir
2. **Gerçek zamanlı**: `startPolling()` ile 5 saniyede bir güncellenir
3. **Alarm kontrolü**: `fetchAlarmData()` ile alarm durumları kontrol edilir
4. **Log görüntüleme**: `fetchLogData()` ile tarihsel veriler çekilir
5. **Kanal yönetimi**: CRUD işlemleri için ilgili metodlar kullanılır

---

## 🔧 HATA YÖNETİMİ

### **Server Response Format:**
```json
{
  "success": false,
  "error": "Hata mesajı açıklaması",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### **HTTP Status Codes:**
- **200**: Başarılı
- **400**: Bad Request (Geçersiz veri)
- **404**: Not Found (Veri bulunamadı)
- **500**: Internal Server Error (Sunucu hatası)

### **Flutter Error Handling:**
```dart
try {
  final data = await restfulService.fetchAllData();
  if (data != null) {
    // Başarılı
  } else {
    // Hata durumu
  }
} catch (e) {
  // Exception handling
}
```

---

## 📈 PERFORMANS ÖZELLİKLERİ

- **Polling Interval**: 5 saniye (ayarlanabilir)
- **Timeout**: 10 saniye (HTTP istekleri için)
- **CORS**: Tüm originlerden erişime izin verilir
- **Threading**: Sunucu multi-threaded çalışır
- **Host**: 0.0.0.0 (tüm network interface'lerde dinler)
- **Port**: 8765 (varsayılan)

---

*Bu dokümantasyon, HIDROLOGGER projesinin Server.py ve Flutter arasındaki tüm JSON veri alışverişini kapsamaktadır.*
