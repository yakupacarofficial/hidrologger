# HIDROLOGGER JSON YAPILARI

## 📋 İÇİNDEKİLER
1. [Server → Flutter (Cihaz Simülasyonu)](#server--flutter-cihaz-simülasyonu)
2. [Flutter → Server (Cihaz Komutları)](#flutter--server-cihaz-komutları)
3. [Veri Yapıları Karşılaştırması](#veri-yapıları-karşılaştırması)
4. [İletişim Protokolü](#iletişim-protokolü)

---

## 🖥️ SERVER → FLUTTER (CİHAZ SİMÜLASYONU)

### 1. Ana Veri Yapısı (API Response)
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
  "timestamp": "2024-01-08T12:34:56.789Z"
}
```

### 2. Channel Verisi (python_server/jsons/variable/channel.json)
```json
{
  "channel": [
    {
      "id": 1,
      "name": "AKIM 3 Parametreli Sensör",
      "description": "Basınç, Sıcaklık ve EC parametrelerini ölçen çok fonksiyonlu sensör",
      "channel_category": 7,
      "channel_sub_category": 8,
      "channel_parameter": 3,
      "measurement_unit": 1,
      "value_type": 8,
      "log_interval": 1000,
      "offset": 12.3
    }
  ]
}
```

### 3. Sensör Verisi (python_server/jsons/variable/data.json)
```json
{
  "data": [
    {
      "id": 1,
      "channel": 1,
      "value_type": 1,
      "value_timestamp": 1754600919,
      "value": 0,
      "battery_percentage": 100,
      "signal_strength": 100
    }
  ]
}
```

### 4. Alarm Verisi (python_server/jsons/alarm/alarm.json)
```json
{
  "parameter1": {
    "channel_id": 1,
    "alarminfo": "Test Alarm",
    "alarms": [
      {
        "min_value": 10.0,
        "max_value": 50.0,
        "color": "#FF0000",
        "data_post_frequency": 1000
      },
      {
        "min_value": 60.0,
        "max_value": 80.0,
        "color": "#00FF00",
        "data_post_frequency": 500
      }
    ]
  }
}
```

---

## 📱 FLUTTER → SERVER (CİHAZ KOMUTLARI)

### 1. Yeni Kanal Ekleme (POST /api/channel)
```json
{
  "id": 4,
  "name": "Test Kanal 4",
  "description": "Otomatik eklenen test kanalı",
  "channel_category": 1,
  "channel_sub_category": 1,
  "channel_parameter": 1,
  "measurement_unit": 1,
  "log_interval": 60,
  "offset": 0.0
}
```

### 2. Kanal Güncelleme (PUT /api/channel/{id})
```json
{
  "field": "name",
  "value": "Yeni Kanal Adı"
}
```

### 3. Alarm Verisi Kaydetme (POST /api/data/alarm)
```json
{
  "parameter1": {
    "channel_id": 1,
    "alarminfo": "Sıcaklık Alarmı",
    "alarms": [
      {
        "min_value": 10.0,
        "max_value": 20.0,
        "color": "#FF0000",
        "data_post_frequency": 1000
      },
      {
        "min_value": 30.0,
        "max_value": 40.0,
        "color": "#00FF00",
        "data_post_frequency": 500
      }
    ]
  }
}
```

### 4. Flutter Sensör Tanımları (lib/jsons_flutter/sensor_installation_wizard/sensors.json)
```json
{
  "sensors": [
    {
      "id": 1,
      "name": "AKIM 3 Parametreli Sensör",
      "description": "Basınç, Sıcaklık ve EC parametrelerini ölçen çok fonksiyonlu sensör",
      "type": "digital",
      "protocol": "4-20 mA",
      "parameters": [
        {
          "id": 1,
          "name": "Basınç",
          "unit": "bar",
          "min_value": 0,
          "max_value": 10,
          "offset": 0.0
        },
        {
          "id": 2,
          "name": "Sıcaklık",
          "unit": "°C",
          "min_value": -10,
          "max_value": 50,
          "offset": 0.0
        },
        {
          "id": 3,
          "name": "EC (Elektriksel İletkenlik)",
          "unit": "mS/cm",
          "min_value": 0,
          "max_value": 200,
          "offset": 0.0
        }
      ]
    }
  ]
}
```

---

## 🔄 VERİ YAPILARI KARŞILAŞTIRMASI

### ✅ UYUMLU ALANLAR
| Flutter Model | Server JSON | Açıklama |
|---------------|-------------|----------|
| `Channel.id` | `channel.id` | ✅ Aynı |
| `Channel.name` | `channel.name` | ✅ Aynı |
| `Channel.description` | `channel.description` | ✅ Aynı |
| `Channel.channelCategory` | `channel.channel_category` | ✅ Snake_case dönüşümü |
| `Channel.channelSubCategory` | `channel.channel_sub_category` | ✅ Snake_case dönüşümü |
| `Channel.channelParameter` | `channel.channel_parameter` | ✅ Snake_case dönüşümü |
| `Channel.measurementUnit` | `channel.measurement_unit` | ✅ Snake_case dönüşümü |
| `Channel.logInterval` | `channel.log_interval` | ✅ Snake_case dönüşümü |
| `Channel.offset` | `channel.offset` | ✅ Aynı |

### ✅ UYUMLU ALANLAR (VariableData)
| Flutter Model | Server JSON | Açıklama |
|---------------|-------------|----------|
| `VariableData.channelId` | `data.channel` | ✅ Aynı |
| `VariableData.value` | `data.value` | ✅ Aynı |
| `VariableData.valueTimestamp` | `data.value_timestamp` | ✅ Snake_case dönüşümü |
| `VariableData.batteryPercentage` | `data.battery_percentage` | ✅ Snake_case dönüşümü |
| `VariableData.signalStrength` | `data.signal_strength` | ✅ Snake_case dönüşümü |
| `VariableData.valueType` | `data.value_type` | ✅ Snake_case dönüşümü |

### ⚠️ FARKLILIKLAR
| Alan | Flutter | Server | Durum |
|------|---------|--------|-------|
| Alarm Yapısı | `AlarmParameter` class | `AlarmParameter` class | ✅ Aynı yapı |
| Value Type | Enum/Int | Int | ✅ Uyumlu |
| Timestamp | DateTime | Unix timestamp | ✅ Dönüşüm var |

---

## 📡 İLETİŞİM PROTOKOLÜ

### 🔄 Veri Akışı
```
[Gerçek Cihaz] ←→ [Python Server] ←→ [Flutter App]
     ↑                    ↑                    ↑
  JSON Data          Simülasyon           UI/Control
```

### 📊 API Endpoints
| Endpoint | Method | Açıklama | Request/Response |
|----------|--------|----------|------------------|
| `/api/data` | GET | Tüm verileri getir | Server → Flutter |
| `/api/data/variable` | GET | Sadece değişken veriler | Server → Flutter |
| `/api/data/alarm` | GET | Alarm verilerini getir | Server → Flutter |
| `/api/data/alarm` | POST | Alarm verilerini kaydet | Flutter → Server |
| `/api/channel` | POST | Yeni kanal oluştur | Flutter → Server |
| `/api/channel/{id}` | PUT | Kanal güncelle | Flutter → Server |
| `/api/channel/{id}` | DELETE | Kanal sil | Flutter → Server |

### 🎯 Önemli Notlar

1. **Snake_case Dönüşümü**: Flutter'da camelCase, Server'da snake_case kullanılıyor
2. **Otomatik Data Bloğu**: Yeni kanal eklendiğinde data.json'a otomatik veri bloğu ekleniyor
3. **Timestamp Formatı**: Server Unix timestamp, Flutter DateTime kullanıyor
4. **✅ Alarm Yapısı**: Flutter ve Server arasında aynı AlarmParameter class yapısı kullanılıyor
5. **Value Type**: Her iki tarafta da integer değerler kullanılıyor
6. **✅ Renk Seçici**: Sensör sihirbazında alarm ekleme ekranına renk seçici eklendi
7. **✅ Her Alarm İçin Ayrı MS Değeri**: Her alarmın kendi data_post_frequency değeri var

### 🔧 Öneriler

1. **✅ Alarm Yapısı Standardize Edildi**: Flutter ve Server arasında aynı alarm JSON yapısı kullanılıyor
2. **Timestamp Standardizasyonu**: ISO 8601 formatını her iki tarafta da kullan
3. **Error Handling**: JSON parse hatalarını daha iyi handle et
4. **Validation**: Gelen JSON verilerini validate et

---

## 📝 SONUÇ

**✅ EVET, JSON YAPILARI TAMAMEN UYUMLU!**

Flutter ve Server arasındaki JSON yapıları tamamen uyumlu. Sadece:
- **Naming Convention**: camelCase ↔ snake_case dönüşümü
- **✅ Alarm Yapısı**: Flutter ve Server arasında aynı AlarmParameter class yapısı kullanılıyor
- **Timestamp Formatı**: Unix ↔ DateTime dönüşümü

Bu farklılıklar Flutter tarafında `fromJson()` ve `toJson()` metodlarıyla otomatik olarak handle ediliyor.
