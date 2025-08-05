import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class ConstantDataService {
  static const String _basePath = 'lib/jsons_flutter/constant';
  
  /// Sabit verileri okur
  static Future<Map<String, dynamic>> loadConstantData() async {
    try {
      final Map<String, dynamic> constantData = {};
      
      // Tüm sabit JSON dosyalarını oku
      final files = [
        'channel_category.json',
        'channel_parameter.json',
        'channel_sub_category.json',
        'measurement_unit.json',
        'value_type.json',
        'station.json',
      ];
      
      for (final file in files) {
        final filePath = '$_basePath/$file';
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = json.decode(jsonString);
        
        // Dosya adından .json uzantısını kaldır
        final key = file.replaceAll('.json', '');
        constantData[key] = jsonData;
      }
      
      return constantData;
    } catch (e) {
      print('Sabit veriler yüklenirken hata: $e');
      return {};
    }
  }
  
  /// Belirli bir sabit veriyi okur
  static Future<Map<String, dynamic>?> loadSpecificConstantData(String fileName) async {
    try {
      final filePath = '$_basePath/$fileName';
      final jsonString = await rootBundle.loadString(filePath);
      return json.decode(jsonString);
    } catch (e) {
      print('$fileName yüklenirken hata: $e');
      return null;
    }
  }
  
  /// Kanal kategorilerini döndürür
  static Future<Map<int, String>> getChannelCategories() async {
    final data = await loadSpecificConstantData('channel_category.json');
    if (data == null || data['channel_category'] == null) return {};
    
    final categories = data['channel_category'] as List<dynamic>;
    return Map.fromEntries(
      categories.map((cat) => MapEntry(
        cat['id'] as int,
        cat['name'] as String,
      )),
    );
  }
  
  /// Kanal parametrelerini döndürür
  static Future<Map<int, String>> getChannelParameters() async {
    final data = await loadSpecificConstantData('channel_parameter.json');
    if (data == null || data['channel_parameter'] == null) return {};
    
    final parameters = data['channel_parameter'] as List<dynamic>;
    return Map.fromEntries(
      parameters.map((param) => MapEntry(
        param['id'] as int,
        param['name'] as String,
      )),
    );
  }
  
  /// Kanal alt kategorilerini döndürür
  static Future<Map<int, String>> getChannelSubCategories() async {
    final data = await loadSpecificConstantData('channel_sub_category.json');
    if (data == null || data['channel_sub_category'] == null) return {};
    
    final subCategories = data['channel_sub_category'] as List<dynamic>;
    return Map.fromEntries(
      subCategories.map((subCat) => MapEntry(
        subCat['id'] as int,
        subCat['name'] as String,
      )),
    );
  }
  
  /// Ölçüm birimlerini döndürür
  static Future<Map<int, String>> getMeasurementUnits() async {
    final data = await loadSpecificConstantData('measurement_unit.json');
    if (data == null || data['measurement_unit'] == null) return {};
    
    final units = data['measurement_unit'] as List<dynamic>;
    return Map.fromEntries(
      units.map((unit) => MapEntry(
        unit['id'] as int,
        unit['description'] as String? ?? unit['name'] as String,
      )),
    );
  }
  
  /// Değer tiplerini döndürür
  static Future<Map<int, String>> getValueTypes() async {
    try {
      final jsonData = await loadSpecificConstantData('value_type.json');
      final valueTypes = jsonData?['value_type'] as List<dynamic>? ?? [];
      final Map<int, String> result = {};
      for (final item in valueTypes) {
        final map = item as Map<String, dynamic>;
        result[map['id'] as int] = map['name'] as String;
      }
      return result;
    } catch (e) {
      print('Value type verileri yüklenirken hata: $e');
      return {};
    }
  }

  static Future<Map<int, String>> getStations() async {
    try {
      final jsonData = await loadSpecificConstantData('station.json');
      final stations = jsonData?['station'] as List<dynamic>? ?? [];
      final Map<int, String> result = {};
      for (final item in stations) {
        final map = item as Map<String, dynamic>;
        result[map['id'] as int] = map['name'] as String;
      }
      return result;
    } catch (e) {
      print('Station verileri yüklenirken hata: $e');
      return {};
    }
  }
} 