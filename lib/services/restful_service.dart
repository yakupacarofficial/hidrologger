import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel_data.dart';

class RESTfulService {
  final String _baseUrl;
  final StreamController<ChannelData> _dataController = StreamController<ChannelData>.broadcast();
  Timer? _pollingTimer;
  bool _isPolling = false;

  RESTfulService({required String ip, required String port}) 
      : _baseUrl = 'http://$ip:$port/api';

  /// Bağlantıyı test et
  Future<bool> testConnection() async {
    try {
      // Bağlantı testi başlatılıyor
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Bağlantı testi hatası
      return false;
    }
  }

  /// Tüm verileri getir
  Future<ChannelData?> fetchAllData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Boş veri durumunu handle et
          final responseData = data['data'];
          if (responseData == null) {
            // Boş veri durumunda varsayılan ChannelData oluştur
            final emptyChannelData = ChannelData(
              timestamp: DateTime.now().toIso8601String(),
              variable: {},
              alarm: {},
            );
            _dataController.add(emptyChannelData);
            return emptyChannelData;
          }
          
          final channelData = ChannelData.fromJson(responseData);
          _dataController.add(channelData);
          return channelData;
        }
      }
      return null;
    } catch (e) {
      // Veri getirme hatası
      return null;
    }
  }

  /// Değişken verileri getir
  Future<Map<String, dynamic>?> fetchVariableData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data/variable'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      // Değişken veri getirme hatası
      return null;
    }
  }

  /// Alarm verilerini getir
  Future<Map<String, dynamic>?> fetchAlarmData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data/alarm'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      // Alarm veri getirme hatası
      return null;
    }
  }

  /// Belirli kanal için log verilerini getir
  Future<Map<String, dynamic>?> fetchLogData(int channelId, {String? startDate, String? endDate}) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$_baseUrl/logs/$channelId').replace(queryParameters: queryParams);
      
      print('Log verisi isteniyor: $uri');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Log verisi yanıtı: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;  // Tüm response'u döndür, sadece data kısmını değil
        } else {
          print('API başarısız: ${data['error']}');
        }
      } else {
        print('HTTP hatası: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Log veri getirme hatası: $e');
      return null;
    }
  }

  /// Belirli kanal için log verisi kaydet
  Future<bool> saveLogData(int channelId, double value, {String? timestamp}) async {
    try {
      final body = <String, dynamic>{
        'value': value,
      };
      if (timestamp != null) body['timestamp'] = timestamp;

      final response = await http.post(
        Uri.parse('$_baseUrl/logs/$channelId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Log veri kaydetme hatası
      return false;
    }
  }

  /// Alarm verilerini kaydet
  Future<bool> saveAlarmData(Map<String, dynamic> alarmData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/data/alarm'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(alarmData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Alarm kaydetme hatası
      return false;
    }
  }

  /// Yeni kanal oluştur
  Future<bool> createChannel(Map<String, dynamic> channelData) async {
    try {
      print('Kanal oluşturma isteği gönderiliyor: $channelData');
      final response = await http.post(
        Uri.parse('$_baseUrl/channel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(channelData),
      ).timeout(const Duration(seconds: 10));

      print('Kanal oluşturma yanıtı: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Kanal oluşturma hatası: $e');
      return false;
    }
  }

  /// Kanalı sil
  Future<bool> deleteChannel(int channelId) async {
    try {
      print('Kanal silme isteği gönderiliyor: $channelId');
      final response = await http.delete(
        Uri.parse('$_baseUrl/channel/$channelId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Kanal silme yanıtı: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Kanal silme hatası: $e');
      return false;
    }
  }

  /// Kanal alanını güncelle
  Future<bool> updateChannelField(int channelId, String field, dynamic value) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/channel/$channelId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'field': field,
          'value': value,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Kanal güncelleme hatası
      return false;
    }
  }

  /// Sunucu bilgilerini getir
  Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/info'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      // Sunucu bilgi getirme hatası
      return null;
    }
  }

  /// Veri akışını başlat
  void startPolling({int intervalSeconds = 5}) {
    if (_isPolling) return;
    
    _isPolling = true;
    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      fetchAllData();
    });
    
    // İlk veriyi hemen getir
    fetchAllData();
  }

  /// Veri akışını durdur
  void stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Veri stream'ini al
  Stream<ChannelData> get dataStream => _dataController.stream;

  /// Verileri zorla yenile
  void forceReload() {
    fetchAllData();
  }

  /// Kaynakları temizle
  void dispose() {
    stopPolling();
    _dataController.close();
  }
} 