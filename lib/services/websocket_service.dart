import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/channel_data.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _lastError = '';
  
  bool get isConnected => _isConnected;
  String get lastError => _lastError;

  Future<bool> connect(String ip, String port) async {
    try {
      final uri = 'ws://$ip:$port';
      _channel = WebSocketChannel.connect(Uri.parse(uri));
      _isConnected = true;
      _lastError = '';
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
    _isConnected = false;
  }

  Stream<ChannelData> get dataStream {
    if (_channel == null) {
      return Stream.empty();
    }
    
    return _channel!.stream.map((data) {
      try {
        final jsonData = jsonDecode(data);
        return ChannelData.fromJson(jsonData);
      } catch (e) {
        throw Exception('JSON parse error: $e');
      }
    });
  }

  void dispose() {
    disconnect();
  }
} 