# Hidrologger Flutter Uygulaması

Bu proje, hidrolojik sensör verilerini izleyen ve yöneten modern bir Flutter mobil uygulamasıdır. Python RESTful API sunucusu ile entegre çalışarak gerçek zamanlı veri izleme, alarm yönetimi ve veri analizi özelliklerini sunar.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Ekranlar](#ekranlar)
- [API Entegrasyonu](#api-entegrasyonu)
- [Alarm Sistemi](#alarm-sistemi)
- [Veri Yönetimi](#veri-yönetimi)
- [Geliştirme](#geliştirme)
- [Build ve Deployment](#build-ve-deployment)
- [Sorun Giderme](#sorun-giderme)

## 🌟 Genel Bakış

Hidrologger Flutter uygulaması, hidrolojik sensörlerden gelen verileri gerçek zamanlı olarak izleyen, alarm yönetimi yapan ve veri analizi sunan kapsamlı bir mobil uygulamadır. Python RESTful API sunucusu ile entegre çalışarak güvenilir ve hızlı veri iletişimi sağlar.

### 🎯 Ana Amaçlar

- **Gerçek Zamanlı İzleme**: Sensör verilerini anlık takip
- **Alarm Yönetimi**: Dinamik alarm kurma ve düzenleme
- **Veri Analizi**: Kanal bazlı veri analizi
- **Çoklu Platform**: Android ve iOS desteği
- **Ağ Uyumluluğu**: WiFi üzerinden otomatik bağlantı

## ✨ Özellikler

### 📱 Mobil Uygulama
- **Flutter Framework**: Modern ve hızlı geliştirme
- **Cross-Platform**: Android ve iOS desteği
- **Responsive Design**: Tüm ekran boyutlarına uyum
- **Material Design**: Modern kullanıcı arayüzü

### 🔄 RESTful API Entegrasyonu
- **HTTP İletişimi**: RESTful API ile veri alışverişi
- **Otomatik Bağlantı**: Ağ tarama ile sunucu bulma
- **Polling Sistemi**: Periyodik veri güncelleme
- **Hata Yönetimi**: Bağlantı sorunlarında otomatik yeniden deneme

### 🚨 Alarm Sistemi
- **Dinamik Alarmlar**: Kullanıcı tanımlı alarm kuralları
- **Renk Kodlaması**: Görsel alarm gösterimi
- **Alarm Bilgileri**: Açıklayıcı alarm mesajları
- **Edit/Silme**: Alarm düzenleme ve silme

### 📊 Veri Yönetimi
- **Yerel JSON**: Sabit verilerin yerel yönetimi
- **Gerçek Zamanlı**: Canlı sensör verileri
- **Kanal Detayları**: Detaylı kanal bilgileri
- **Veri Geçmişi**: Kanal bazlı veri geçmişi

## 🛠️ Kurulum

### Gereksinimler

- Flutter SDK 3.8+
- Dart 3.0+
- Android Studio / Xcode
- Python Server (Hidrologger Backend)

### Adım Adım Kurulum

1. **Flutter Kurulumu**
   ```bash
   # Flutter'ın kurulu olduğunu kontrol edin
   flutter --version
   
   # Flutter doctor ile sistem kontrolü
   flutter doctor
   ```

2. **Proje Klonlama**
   ```bash
   git clone https://github.com/yakupacarofficial/hidrologger.git
   cd hidrologger
   ```

3. **Bağımlılıkları Yükleme**
   ```bash
   flutter pub get
   ```

4. **Uygulamayı Çalıştırma**
   ```bash
   # Web için
   flutter run -d chrome
   
   # Android için
   flutter run -d android
   
   # iOS için
   flutter run -d ios
   ```

### Hızlı Başlangıç

```bash
# Tek komutla kurulum ve çalıştırma
git clone https://github.com/yakupacarofficial/hidrologger.git && \
cd hidrologger && \
flutter pub get && \
flutter run -d chrome
```

## 🚀 Kullanım

### İlk Kurulum

1. **Uygulamayı Açın**: Hidrologger uygulamasını başlatın
2. **Ağ Taraması**: Otomatik sunucu arama
3. **Bağlantı**: Bulunan sunucuya bağlanın
4. **Dashboard**: Ana ekrana yönlendirme

### Sunucu Bağlantısı

#### Otomatik Bağlantı
- Uygulama otomatik olarak ağdaki sunucuyu arar
- Bulunan sunucular listelenir
- Tek tıkla bağlantı kurulur

#### Manuel Bağlantı
- IP adresi ve port girin
- Bağlantı testi yapın
- Başarılı bağlantıda dashboard'a yönlendirilir

### Veri İzleme

1. **Dashboard**: Ana ekranda tüm kanalları görün
2. **Kanal Detayı**: Kanal kartına tıklayın
3. **Gerçek Zamanlı**: Canlı veri akışını izleyin
4. **Geçmiş Veri**: Veri geçmişini görüntüleyin

## 📱 Ekranlar

### 🔗 Bağlantı Ekranı (ConnectionScreen)
- **Ağ Tarama**: Otomatik sunucu bulma
- **Manuel Giriş**: IP ve port girişi
- **Bağlantı Testi**: Sunucu erişim kontrolü
- **Durum Gösterimi**: Bağlantı durumu

### 📊 Dashboard Ekranı (DashboardScreen)
- **Kanal Listesi**: Tüm kanalların görünümü
- **Gerçek Zamanlı Veri**: Canlı sensör verileri
- **Arama**: Kanal ismine göre filtreleme
- **Alarm Yönetimi**: Alarm ekranına erişim

### 🔍 Kanal Detay Ekranı (ChannelDetailScreen)
- **Kanal Bilgileri**: Detaylı kanal özellikleri
- **Veri Geçmişi**: Kanal veri geçmişi
- **Düzenleme**: Log interval ve offset düzenleme
- **Gerçek Zamanlı**: Canlı veri akışı

### 🚨 Alarm Yönetim Ekranı (AlarmManagementScreen)
- **Alarm Ekleme**: Yeni alarm kurma
- **Alarm Listesi**: Mevcut alarmları görüntüleme
- **Alarm Düzenleme**: Alarm değerlerini değiştirme
- **Alarm Silme**: Alarmları kaldırma

### 📋 Sabit Veriler Ekranı (ConstantDataScreen)
- **Kanal Kategorileri**: Ana kategori listesi
- **Alt Kategoriler**: Alt kategori listesi
- **Parametreler**: Ölçüm parametreleri
- **Birimler**: Ölçüm birimleri
- **Değer Tipleri**: Veri tipleri
- **İstasyonlar**: İstasyon bilgileri

## 🔌 API Entegrasyonu

### RESTfulService
```dart
class RESTfulService {
  // Bağlantı testi
  Future<bool> testConnection()
  
  // Veri alma
  Future<ChannelData?> fetchAllData()
  
  // Alarm yönetimi
  Future<Map<String, dynamic>?> fetchAlarmData()
  Future<bool> saveAlarmData(Map<String, dynamic> alarmData)
  
  // Kanal güncelleme
  Future<bool> updateChannelField(int channelId, String field, dynamic value)
}
```

### Endpoint'ler
- `GET /api/health` - Sunucu durumu
- `GET /api/data` - Tüm veriler
- `GET /api/data/variable` - Değişken veriler
- `GET /api/data/alarm` - Alarm verileri
- `POST /api/data/alarm` - Alarm kaydetme
- `PUT /api/channel/{id}` - Kanal güncelleme

### Ağ Tarama
```dart
// Otomatik IP bulma
Future<String> _getLocalIP()

// Ağ tarama
Future<void> _scanNetwork()

// Test IP'leri
List<String> _generateTestIPs(String subnet)
```

## 🚨 Alarm Sistemi

### Alarm Yapısı
```dart
class Alarm {
  final double minValue;
  final double maxValue;
  final String color;
}

class AlarmParameter {
  final int channelId;
  final int dataPostFrequency;
  final String alarmInfo;
  final List<Alarm> alarms;
}
```

### Alarm Özellikleri
- **Min/Max Değerler**: Sayısal aralık tanımlama
- **Renk Seçimi**: 10 farklı renk seçeneği
- **Alarm Bilgisi**: Açıklayıcı mesaj
- **Veri Sıklığı**: Gönderme aralığı ayarı

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

## 📊 Veri Yönetimi

### Yerel JSON Dosyaları
```
lib/jsons_flutter/constant/
├── channel_category.json
├── channel_parameter.json
├── channel_sub_category.json
├── measurement_unit.json
├── value_type.json
└── station.json
```

### ConstantDataService
```dart
class ConstantDataService {
  // Tüm sabit verileri yükle
  static Future<Map<String, dynamic>> loadConstantData()
  
  // Belirli veriyi yükle
  static Future<Map<String, dynamic>?> loadSpecificConstantData(String fileName)
  
  // Kategoriler
  static Future<Map<int, String>> getChannelCategories()
  static Future<Map<int, String>> getChannelParameters()
  static Future<Map<int, String>> getMeasurementUnits()
}
```

### Veri Modelleri
```dart
class ChannelData {
  final List<Channel> channels;
  final List<VariableData> variableData;
  final Map<String, AlarmParameter> alarmParameters;
}

class Channel {
  final int id;
  final String name;
  final String description;
  // ... diğer özellikler
}

class VariableData {
  final int channelId;
  final double value;
  final int valueTimestamp;
  // ... diğer özellikler
}
```

## 🔧 Geliştirme

### Proje Yapısı
```
lib/
├── main.dart                    # Ana uygulama
├── models/                      # Veri modelleri
│   └── channel_data.dart
├── services/                    # Servisler
│   ├── restful_service.dart
│   └── constant_data_service.dart
├── screens/                     # Ekranlar
│   ├── connection_screen.dart
│   ├── dashboard_screen.dart
│   ├── channel_detail_screen.dart
│   ├── alarm_management_screen.dart
│   └── constant_data_screen.dart
├── widgets/                     # Widget'lar
│   ├── info_card.dart
│   ├── data_item.dart
│   └── connection_status_badge.dart
└── jsons_flutter/              # Yerel JSON dosyaları
    └── constant/
```

### Yeni Ekran Ekleme
```dart
class YeniEkran extends StatefulWidget {
  @override
  _YeniEkranState createState() => _YeniEkranState();
}

class _YeniEkranState extends State<YeniEkran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Ekran')),
      body: Container(),
    );
  }
}
```

### Yeni Servis Ekleme
```dart
class YeniService {
  static Future<dynamic> yeniFonksiyon() async {
    try {
      // İşlemler
      return sonuc;
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }
}
```

## 📦 Build ve Deployment

### Debug Build
```bash
# Web için
flutter run -d chrome

# Android için
flutter run -d android

# iOS için
flutter run -d ios
```

### Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### APK Dosyası
- **Konum**: `build/app/outputs/flutter-apk/app-release.apk`
- **Boyut**: ~21.9 MB
- **Platform**: Android 5.0+

### Web Deployment
```bash
# Web build
flutter build web

# Web sunucusu başlatma
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

## 🐛 Sorun Giderme

### Yaygın Sorunlar

#### 1. Bağlantı Hatası
```bash
# Sunucunun çalıştığını kontrol edin
curl http://[IP]:8765/api/health

# Ağ taraması yapın
python3 network_scan.py
```

#### 2. Flutter Build Hatası
```bash
# Cache temizleme
flutter clean

# Bağımlılıkları yeniden yükleme
flutter pub get

# Flutter doctor
flutter doctor
```

#### 3. API Timeout
- Sunucu IP adresini kontrol edin
- Firewall ayarlarını kontrol edin
- Aynı WiFi ağında olduğunuzdan emin olun

#### 4. JSON Dosya Hatası
```bash
# JSON dosyalarının varlığını kontrol edin
ls -la lib/jsons_flutter/constant/
```

### Debug Modu
```dart
// Debug print'leri
print('Debug mesajı');

// Hata yakalama
try {
  // İşlemler
} catch (e) {
  print('Hata: $e');
}
```

### Log Seviyeleri
```dart
// Detaylı loglar için
import 'dart:developer' as developer;

developer.log('Detaylı log mesajı', name: 'Hidrologger');
```

## 📞 Destek

### İletişim
- **Geliştirici**: Hidrologger AKIM ELEKTRONIK
- **Versiyon**: 1.0.0
- **Son Güncelleme**: 2025-08-05

### Teknik Detaylar
- **Framework**: Flutter 3.8+
- **Dil**: Dart 3.0+
- **API**: RESTful HTTP
- **Veri Formatı**: JSON
- **Platform**: Android, iOS, Web

### Gereksinimler
- **Android**: API Level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern tarayıcılar
- **Sunucu**: Python Flask RESTful API

---

**Not**: Bu uygulama, Hidrologger Python Server ile birlikte çalışmak üzere tasarlanmıştır.