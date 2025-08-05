import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/channel_data.dart';

class RESTfulService {
  static const Duration _pollingInterval = Duration(seconds: 2);
  
  final String _ip;
  final String _port;
  late final String _baseUrl;
  
  Timer? _pollingTimer;
  ChannelData? _lastData;
  final StreamController<ChannelData> _dataController = StreamController<ChannelData>.broadcast();
  
  RESTfulService({String? ip, String? port}) 
    : _ip = ip ?? '192.168.10.68',
      _port = port ?? '8765' {
    _baseUrl = 'http://$_ip:$_port/api';
    print('RESTfulService başlatıldı: $_baseUrl');
  }
  
  Stream<ChannelData> get dataStream => _dataController.stream;
  ChannelData? get lastData => _lastData;
  
  /// Sunucu bağlantısını test et
  Future<bool> testConnection() async {
    try {
      print('Bağlantı testi başlatılıyor: $_baseUrl/health');
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('Sunucu yanıtı: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] == true;
        print('Bağlantı testi sonucu: $success');
        return success;
      }
      print('Bağlantı testi başarısız: HTTP ${response.statusCode}');
      return false;
    } catch (e) {
      print('Bağlantı testi hatası: $e');
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
          final channelData = ChannelData.fromJson(data['data']);
          _lastData = channelData;
          _dataController.add(channelData);
          return channelData;
        }
      }
      return null;
    } catch (e) {
      print('Veri getirme hatası: $e');
      return null;
    }
  }
  
  /// Sadece değişken verileri getir
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
      print('Değişken veri getirme hatası: $e');
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
      print('Alarm veri getirme hatası: $e');
      return null;
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
      print('Alarm kaydetme hatası: $e');
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
      print('Kanal güncelleme hatası: $e');
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
      print('Sunucu bilgi getirme hatası: $e');
      return null;
    }
  }
  
  /// Periyodik veri güncellemesini başlat
  void startPolling() {
    stopPolling(); // Önceki polling'i durdur
    
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      await fetchAllData();
    });
    
    print('Periyodik veri güncellemesi başlatıldı (${_pollingInterval.inSeconds} saniye aralıkla)');
  }
  
  /// Periyodik veri güncellemesini durdur
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('Periyodik veri güncellemesi durduruldu');
  }
  
  /// Bağlantıyı kapat
  void dispose() {
    stopPolling();
    _dataController.close();
    print('RESTful servis kapatıldı');
  }
} 