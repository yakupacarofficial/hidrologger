import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/channel_data.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _lastError = '';
  Stream<ChannelData>? _dataStream;
  ChannelData? _lastData;
  
  bool get isConnected => _isConnected;
  String get lastError => _lastError;
  ChannelData? get lastData => _lastData;

  Future<bool> connect(String ip, String port) async {
    try {
      final uri = 'ws://$ip:$port';
      _channel = WebSocketChannel.connect(Uri.parse(uri));
      _isConnected = true;
      _lastError = '';
      
      // Stream'i oluştur
      _dataStream = _channel!.stream.map((data) {
        try {
          final jsonData = jsonDecode(data);
          _lastData = ChannelData.fromJson(jsonData);
          return _lastData!;
        } catch (e) {
          throw Exception('JSON parse error: $e');
        }
      }).asBroadcastStream(); // Broadcast stream yap
      
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isConnected = false;
      return false;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _dataStream = null;
    _isConnected = false;
  }

  Stream<ChannelData> get dataStream {
    if (_dataStream == null) {
      return Stream.empty();
    }
    return _dataStream!;
  }

  void dispose() {
    disconnect();
  }

  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (_channel == null || !_isConnected) {
      _lastError = 'WebSocket bağlantısı yok';
      return false;
    }
    
    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      return true;
    } catch (e) {
      _lastError = 'Mesaj gönderme hatası: $e';
      return false;
    }
  }
} 