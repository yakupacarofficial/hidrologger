# Hidrolink - Hidrolojik İzleme Sistemi

Bu proje, hidrolojik sensör verilerini izleyen ve yöneten modern bir Flutter mobil uygulamasıdır. Python RESTful API sunucusu ile entegre çalışarak gerçek zamanlı veri izleme, alarm yönetimi, log kayıtları ve veri analizi özelliklerini sunar.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Ekranlar](#ekranlar)
- [API Entegrasyonu](#api-entegrasyonu)
- [Log Sistemi](#log-sistemi)
- [Alarm Sistemi](#alarm-sistemi)
- [Veri Yönetimi](#veri-yönetimi)
- [Geliştirme](#geliştirme)
- [Build ve Deployment](#build-ve-deployment)
- [Sorun Giderme](#sorun-giderme)

## 🌟 Genel Bakış

Hidrolink Flutter uygulaması, hidrolojik sensörlerden gelen verileri gerçek zamanlı olarak izleyen, alarm yönetimi yapan, log kayıtları tutan ve veri analizi sunan kapsamlı bir mobil uygulamadır. Python RESTful API sunucusu ile entegre çalışarak güvenilir ve hızlı veri iletişimi sağlar.

### 🎯 Ana Amaçlar

- **Gerçek Zamanlı İzleme**: Sensör verilerini anlık takip
- **Alarm Yönetimi**: Dinamik alarm kurma ve düzenleme
- **Log Kayıtları**: Tarih bazlı veri geçmişi ve grafik analizi
- **Veri Analizi**: Kanal bazlı veri analizi (min/max değerler)
- **Çoklu Platform**: Android ve iOS desteği
- **Ağ Uyumluluğu**: WiFi üzerinden otomatik bağlantı
- **Splash Screen**: Animasyonlu açılış ekranı

## ✨ Özellikler

### 📱 Mobil Uygulama
- **Flutter Framework**: Modern ve hızlı geliştirme
- **Cross-Platform**: Android ve iOS desteği
- **Responsive Design**: Tüm ekran boyutlarına uyum
- **Material Design**: Modern kullanıcı arayüzü
- **Animasyonlar**: Smooth geçişler ve animasyonlar

### 🔄 RESTful API Entegrasyonu
- **HTTP İletişimi**: RESTful API ile veri alışverişi
- **Otomatik Bağlantı**: Ağ tarama ile sunucu bulma
- **Polling Sistemi**: Periyodik veri güncelleme
- **Hata Yönetimi**: Bağlantı sorunlarında otomatik yeniden deneme
- **Background Monitoring**: Arka planda sürekli veri izleme

### 📊 Log Sistemi
- **Tarih Bazlı Filtreleme**: Bugün, Son 24 Saat, Son 7 Gün, Son 1 Ay, Custom
- **Grafik Görünümü**: Veri trendlerini görselleştirme
- **Tablo Görünümü**: Detaylı log kayıtları
- **Min/Max Değerler**: Her kayıt için minimum ve maksimum değerler
- **Otomatik Loglama**: Veri değişikliklerinde otomatik kayıt

### 🚨 Alarm Sistemi
- **Dinamik Alarmlar**: Kullanıcı tanımlı alarm kuralları
- **Renk Kodlaması**: Görsel alarm gösterimi
- **Alarm Bilgileri**: Açıklayıcı alarm mesajları
- **Edit/Silme**: Alarm düzenleme ve silme
- **Çoklu Alarm**: Her kanal için birden fazla alarm

### 📊 Veri Yönetimi
- **Yerel JSON**: Sabit verilerin yerel yönetimi
- **Gerçek Zamanlı**: Canlı sensör verileri
- **Kanal Detayları**: Detaylı kanal bilgileri
- **Veri Geçmişi**: Kanal bazlı veri geçmişi
- **Min/Max Hesaplama**: Otomatik minimum ve maksimum değer hesaplama

### 🌐 Ağ ve Sistem Bilgileri
- **WiFi IP Adresi**: Bağlı olduğunuz ağın IP adresi
- **İstasyon Bilgileri**: İstasyon adı ve kodu
- **Bağlantı Durumu**: Sunucu bağlantı durumu

## 🛠️ Kurulum

### Gereksinimler

- Flutter SDK 3.8+
- Dart 3.0+
- Android Studio / Xcode
- Python Server (Hidrolink Backend)

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

4. **Python Server Kurulumu**
   ```bash
   cd python_server
   pip3 install -r requirements.txt
   python3 server.py
   ```

5. **Uygulamayı Çalıştırma**
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
cd python_server && \
python3 server.py &
flutter run -d chrome
```

## 🚀 Kullanım

### İlk Kurulum

1. **Splash Screen**: Animasyonlu açılış ekranı
2. **Bağlantı Ekranı**: Otomatik sunucu arama
3. **Dashboard**: Ana ekrana yönlendirme
4. **Veri İzleme**: Gerçek zamanlı sensör verileri

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
4. **Log Kayıtları**: Tarih bazlı veri geçmişi
5. **Grafik Analizi**: Veri trendlerini görselleştirin

### Log Sistemi Kullanımı

1. **Kanal Detayına Gidin**: Herhangi bir kanalı seçin
2. **LOG KAYITLARI Butonu**: Ekranın altında bulunur
3. **Tarih Seçimi**: Önceden tanımlı aralıklar veya custom
4. **Grafik Görünümü**: Veri trendlerini inceleyin
5. **Tablo Görünümü**: Detaylı kayıtları görüntüleyin

## 📱 Ekranlar

### 🎬 Splash Screen
- **Animasyonlu Logo**: Scale ve fade animasyonları
- **Hidro Link Yazısı**: Slide ve color animasyonları
- **Otomatik Geçiş**: 3 saniye sonra bağlantı ekranına

### 🔗 Bağlantı Ekranı (ConnectionScreen)
- **Ağ Tarama**: Otomatik sunucu bulma
- **Manuel Giriş**: IP ve port girişi
- **Bağlantı Testi**: Sunucu erişim kontrolü
- **Durum Gösterimi**: Bağlantı durumu

### 📊 Dashboard Ekranı (DashboardScreen)
- **Üst Bilgi Kartları**: Toplam kanal, aktif kanal, toplam alarm
- **İstasyon Bilgileri**: İstasyon adı, kodu ve WiFi IP adresi
- **Kanal Listesi**: Tüm kanalların görünümü
- **Gerçek Zamanlı Veri**: Canlı sensör verileri (değer, min, max)
- **Arama**: Kanal ismine göre filtreleme
- **Responsive Tasarım**: Klavye açıldığında uyumlu layout

### 🔍 Kanal Detay Ekranı (ChannelDetailScreen)
- **Kanal Bilgileri**: Detaylı kanal özellikleri
- **Veri Gösterimi**: Mevcut değer, minimum, maksimum
- **Düzenleme**: Log interval ve offset düzenleme
- **Gerçek Zamanlı**: Canlı veri akışı
- **LOG KAYITLARI**: Log ekranına erişim

### 📈 Log Ekranı (LogScreen)
- **Tarih Seçimi**: Bugün, Son 24 Saat, Son 7 Gün, Son 1 Ay, Custom
- **Grafik Görünümü**: Veri trendlerini görselleştirme
- **Tablo Görünümü**: Detaylı log kayıtları
- **Filtreleme**: Tarih bazlı veri filtreleme
- **Responsive**: Tüm ekran boyutlarına uyum

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
  
  // Log verileri
  Future<Map<String, dynamic>?> fetchLogData(int channelId, {String? startDate, String? endDate})
  Future<bool> saveLogData(int channelId, Map<String, dynamic> logData)
  
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
- `GET /api/data/variable` - Değişken veriler (min/max dahil)
- `GET /api/data/alarm` - Alarm verileri
- `POST /api/data/alarm` - Alarm kaydetme
- `PUT /api/channel/{id}` - Kanal güncelleme
- `GET /api/logs/{channelId}` - Log verileri (tarih filtreli)
- `POST /api/logs/{channelId}` - Log kaydetme
- `GET /api/monitoring/status` - Monitoring durumu

### Ağ Tarama
```dart
// Otomatik IP bulma
Future<String> _getLocalIP()

// Ağ tarama
Future<void> _scanNetwork()

// Test IP'leri
List<String> _generateTestIPs(String subnet)
```

## 📊 Log Sistemi

### Tarih Filtreleme
- **Bugün**: Günün başından şu ana kadar
- **Son 24 Saat**: Son 24 saat
- **Son 7 Gün**: Son 7 gün
- **Son 1 Ay**: Son 1 ay
- **Custom**: Kullanıcı tanımlı tarih aralığı

### Log Veri Yapısı
```dart
class LogEntry {
  final int id;
  final DateTime timestamp;
  final double value;
  final double minValue;
  final double maxValue;
  final String quality;
  final int batteryPercentage;
  final int signalStrength;
}
```

### Grafik Görünümü
- **Line Chart**: Veri trendlerini gösterir
- **Responsive**: Ekran boyutuna uyum sağlar
- **Hata Yönetimi**: Veri yoksa uygun mesaj gösterir

### Tablo Görünümü
- **Liste Formatı**: Tüm log kayıtları
- **Sıralama**: Tarih bazlı sıralama
- **Detaylar**: Her kayıt için tüm bilgiler

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
  final double minValue;
  final double maxValue;
  final int valueTimestamp;
  // ... diğer özellikler
}
```

### StationService
```dart
class StationService {
  // İstasyon bilgilerini yükle
  static Future<Map<String, dynamic>?> getStationInfo()
  
  // WiFi IP adresini al
  static Future<String?> getWiFiIPAddress()
}
```

## 🔧 Geliştirme

### Proje Yapısı
```
lib/
├── main.dart                    # Ana uygulama (HidrolinkApp)
├── models/                      # Veri modelleri
│   └── channel_data.dart       # Min/max değerler dahil
├── services/                    # Servisler
│   ├── restful_service.dart    # API iletişimi
│   ├── constant_data_service.dart
│   └── station_service.dart    # İstasyon ve WiFi bilgileri
├── screens/                     # Ekranlar
│   ├── splash_screen.dart      # Animasyonlu açılış
│   ├── connection_screen.dart
│   ├── dashboard_screen.dart   # Responsive tasarım
│   ├── channel_detail_screen.dart
│   ├── alarm_management_screen.dart
│   ├── constant_data_screen.dart
│   └── logs/                   # Log sistemi
│       ├── log_screen.dart
│       ├── date_selection_widget.dart
│       ├── log_chart_widget.dart
│       └── log_table_widget.dart
├── widgets/                     # Widget'lar
│   ├── info_card.dart          # Güncellenmiş tasarım
│   ├── data_item.dart          # Min/max değerler
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

#### 5. Log Verisi Görünmüyor
- Python server'ın çalıştığından emin olun
- `logs.json` dosyasında veri olduğunu kontrol edin
- Tarih filtreleme parametrelerini kontrol edin

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

developer.log('Detaylı log mesajı', name: 'Hidrolink');
```

## 📞 Destek

### İletişim
- **Geliştirici**: Hidrolink AKIM ELEKTRONIK
- **Versiyon**: 1.0.0
- **Son Güncelleme**: 2025-08-11

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

### Bağımlılıklar
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.19.0
  network_info_plus: ^4.1.0
```

---

**Not**: Bu uygulama, Hidrolink Python Server ile birlikte çalışmak üzere tasarlanmıştır. Tüm özellikler için Python server'ın çalışır durumda olması gereklidir.