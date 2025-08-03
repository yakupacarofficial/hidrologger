import 'dart:convert';
import 'package:flutter/services.dart';

class ConstantDataService {
  static final ConstantDataService _instance = ConstantDataService._internal();
  factory ConstantDataService() => _instance;
  ConstantDataService._internal();

  Map<String, dynamic>? _constantData;

  Future<Map<String, dynamic>> getConstantData() async {
    if (_constantData != null) {
      return _constantData!;
    }

    try {
      // WebSocket'ten gelen veriyi kullanacağız
      // Bu servis sadece constant verilerini organize etmek için
      return {};
    } catch (e) {
      print('Constant data yüklenirken hata: $e');
      return {};
    }
  }

  List<Map<String, dynamic>> getChannelCategories(Map<String, dynamic> constantData) {
    try {
      final categories = constantData['channel_category'] as List<dynamic>? ?? [];
      return categories.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getChannelSubCategories(Map<String, dynamic> constantData) {
    try {
      final subCategories = constantData['channel_sub_category'] as List<dynamic>? ?? [];
      return subCategories.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getChannelParameters(Map<String, dynamic> constantData) {
    try {
      final parameters = constantData['channel_parameter'] as List<dynamic>? ?? [];
      return parameters.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getChannels(Map<String, dynamic> constantData) {
    try {
      final channels = constantData['channel'] as List<dynamic>? ?? [];
      return channels.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getMeasurementUnits(Map<String, dynamic> constantData) {
    try {
      final units = constantData['measurement_unit'] as List<dynamic>? ?? [];
      return units.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getStations(Map<String, dynamic> constantData) {
    try {
      final stations = constantData['station'] as List<dynamic>? ?? [];
      return stations.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getValueTypes(Map<String, dynamic> constantData) {
    try {
      final valueTypes = constantData['value_type'] as List<dynamic>? ?? [];
      return valueTypes.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  String getCategoryName(int id, Map<String, dynamic> constantData) {
    final categories = getChannelCategories(constantData);
    final category = categories.firstWhere(
      (cat) => cat['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'Kategori bulunamadı'},
    );
    return category['name'] ?? 'Bilinmeyen';
  }

  String getSubCategoryName(int id, Map<String, dynamic> constantData) {
    final subCategories = getChannelSubCategories(constantData);
    final subCategory = subCategories.firstWhere(
      (subCat) => subCat['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'Alt kategori bulunamadı'},
    );
    return subCategory['name'] ?? 'Bilinmeyen';
  }

  String getParameterName(int id, Map<String, dynamic> constantData) {
    final parameters = getChannelParameters(constantData);
    final parameter = parameters.firstWhere(
      (param) => param['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'Parametre bulunamadı'},
    );
    return parameter['name'] ?? 'Bilinmeyen';
  }

  String getUnitName(int id, Map<String, dynamic> constantData) {
    final units = getMeasurementUnits(constantData);
    final unit = units.firstWhere(
      (unit) => unit['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'Birim bulunamadı'},
    );
    return unit['name'] ?? 'Bilinmeyen';
  }

  String getStationName(int id, Map<String, dynamic> constantData) {
    final stations = getStations(constantData);
    final station = stations.firstWhere(
      (station) => station['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'İstasyon bulunamadı'},
    );
    return station['name'] ?? 'Bilinmeyen';
  }

  String getValueTypeName(int id, Map<String, dynamic> constantData) {
    final valueTypes = getValueTypes(constantData);
    final valueType = valueTypes.firstWhere(
      (vt) => vt['id'] == id,
      orElse: () => {'name': 'Bilinmeyen', 'description': 'Değer tipi bulunamadı'},
    );
    return valueType['name'] ?? 'Bilinmeyen';
  }
} 