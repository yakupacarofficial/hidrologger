import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class StationService {
  static const String _stationPath = 'lib/jsons_flutter/constant/station.json';
  
  Future<Map<String, dynamic>?> getStationInfo() async {
    try {
      final String jsonString = await rootBundle.loadString(_stationPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      if (jsonData.containsKey('station') && jsonData['station'] is List && jsonData['station'].isNotEmpty) {
        return jsonData['station'][0]; // İlk station bilgisini döndür
      }
      
      return null;
    } catch (e) {
      print('Station bilgileri okunamadı: $e');
      return null;
    }
  }
  
  Future<String?> getWiFiIPAddress() async {
    try {
      // Network interface'lerini kontrol et
      for (NetworkInterface interface in await NetworkInterface.list()) {
        // WiFi interface'ini bul (genellikle wlan0, en0, etc.)
        if (interface.name.toLowerCase().contains('wlan') || 
            interface.name.toLowerCase().contains('en') ||
            interface.name.toLowerCase().contains('wi-fi')) {
          
          for (InternetAddress address in interface.addresses) {
            // IPv4 adresini döndür
            if (address.type == InternetAddressType.IPv4 && 
                !address.address.startsWith('127.')) {
              return address.address;
            }
          }
        }
      }
      
      // WiFi bulunamazsa ilk IPv4 adresini döndür
      for (NetworkInterface interface in await NetworkInterface.list()) {
        for (InternetAddress address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && 
              !address.address.startsWith('127.')) {
            return address.address;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('WiFi IP adresi alınamadı: $e');
      return null;
    }
  }
}
