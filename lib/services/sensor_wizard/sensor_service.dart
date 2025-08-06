import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/sensor_wizard/sensor.dart';
import '../../models/sensor_wizard/protocol.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  List<Sensor>? _sensors;
  List<Protocol>? _protocols;

  /// Kayıtlı sensörleri yükle
  Future<List<Sensor>> loadSensors() async {
    if (_sensors != null) return _sensors!;

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/jsons_flutter/sensor_installation_wizard/sensors.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _sensors = (jsonData['sensors'] as List)
          .map((sensorJson) => Sensor.fromJson(sensorJson))
          .toList();
      
      return _sensors!;
    } catch (e) {
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  /// Protokolleri yükle
  Future<List<Protocol>> loadProtocols() async {
    if (_protocols != null) return _protocols!;

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/jsons_flutter/sensor_installation_wizard/protocols.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _protocols = (jsonData['protocols'] as List)
          .map((protocolJson) => Protocol.fromJson(protocolJson))
          .toList();
      
      return _protocols!;
    } catch (e) {
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  /// ID'ye göre sensör bul
  Sensor? getSensorById(int id) {
    return _sensors?.firstWhere(
      (sensor) => sensor.id == id,
      orElse: () => throw Exception('Sensör bulunamadı: $id'),
    );
  }

  /// ID'ye göre protokol bul
  Protocol? getProtocolById(int id) {
    return _protocols?.firstWhere(
      (protocol) => protocol.id == id,
      orElse: () => throw Exception('Protokol bulunamadı: $id'),
    );
  }

  /// Analog sensörleri getir
  List<Sensor> getAnalogSensors() {
    return _sensors?.where((sensor) => sensor.type == 'analog').toList() ?? [];
  }

  /// Dijital sensörleri getir
  List<Sensor> getDigitalSensors() {
    return _sensors?.where((sensor) => sensor.type == 'digital').toList() ?? [];
  }

  /// Akım protokollerini getir
  List<Protocol> getCurrentProtocols() {
    return _protocols?.where((protocol) => protocol.type == 'current').toList() ?? [];
  }

  /// Voltaj protokollerini getir
  List<Protocol> getVoltageProtocols() {
    return _protocols?.where((protocol) => protocol.type == 'voltage').toList() ?? [];
  }
} 