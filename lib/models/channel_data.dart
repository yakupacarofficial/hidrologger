class ChannelData {
  final String timestamp;
  final Map<String, dynamic> constant;
  final Map<String, dynamic> variable;
  final Map<String, dynamic> alarm;

  ChannelData({
    required this.timestamp,
    required this.constant,
    required this.variable,
    required this.alarm,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    return ChannelData(
      timestamp: json['timestamp'] ?? '',
      constant: json['constant'] ?? {},
      variable: json['variable'] ?? {},
      alarm: json['alarm'] ?? {},
    );
  }

  List<Channel> get channels {
    final channelData = constant['channel'] as List<dynamic>? ?? [];
    return channelData.map((channel) => Channel.fromJson(channel, this)).toList();
  }

  List<VariableData> get variableData {
    final data = variable['data'] as List<dynamic>? ?? [];
    return data.map((item) => VariableData.fromJson(item)).toList();
  }

  // Constant verileri için getter'lar
  Map<int, String> get channelCategories {
    final categories = constant['channel_category'] as List<dynamic>? ?? [];
    return Map.fromEntries(
      categories.map((cat) => MapEntry(
        cat['id'] as int,
        cat['name'] as String,
      )),
    );
  }

  Map<int, String> get channelSubCategories {
    final subCategories = constant['channel_sub_category'] as List<dynamic>? ?? [];
    return Map.fromEntries(
      subCategories.map((subCat) => MapEntry(
        subCat['id'] as int,
        subCat['name'] as String,
      )),
    );
  }

  Map<int, String> get channelParameters {
    final parameters = constant['channel_parameter'] as List<dynamic>? ?? [];
    return Map.fromEntries(
      parameters.map((param) => MapEntry(
        param['id'] as int,
        param['name'] as String,
      )),
    );
  }

  Map<int, String> get measurementUnits {
    final units = constant['measurement_unit'] as List<dynamic>? ?? [];
    return Map.fromEntries(
      units.map((unit) => MapEntry(
        unit['id'] as int,
        unit['description'] as String? ?? unit['name'] as String,
      )),
    );
  }

  int get channelCount => channels.length;
  int get dataCount => variableData.length;
}

class Channel {
  final int id;
  final String name;
  final String description;
  final int channelCategory;
  final int channelSubCategory;
  final int channelParameter;
  final int measurementUnit;
  final int logInterval;
  final double offset;
  final ChannelData? channelData; // ChannelData referansı ekledik

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.channelCategory,
    required this.channelSubCategory,
    required this.channelParameter,
    required this.measurementUnit,
    required this.logInterval,
    required this.offset,
    this.channelData,
  });

  factory Channel.fromJson(Map<String, dynamic> json, ChannelData channelData) {
    return Channel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      channelCategory: json['channel_category'] ?? 0,
      channelSubCategory: json['channel_sub_category'] ?? 0,
      channelParameter: json['channel_parameter'] ?? 0,
      measurementUnit: json['measurement_unit'] ?? 0,
      logInterval: json['log_interval'] ?? 0,
      offset: (json['offset'] ?? 0.0).toDouble(),
      channelData: channelData,
    );
  }

  String get unit {
    if (channelData != null) {
      return channelData!.measurementUnits[measurementUnit] ?? 'Bilinmeyen';
    }
    // Fallback değerler
    switch (measurementUnit) {
      case 2: return 'm³';
      case 3: return 'm³/h';
      case 4: return 'cm';
      case 5: return 'm';
      case 7: return 'mm';
      case 8: return 'bar';
      case 9: return 'μS';
      case 10: return '°C';
      case 11: return 'mg/l';
      case 12: return 'pH';
      case 13: return 'NTU';
      case 15: return '%';
      case 19: return 'm³/sn';
      default: return 'Bilinmeyen';
    }
  }

  String get category {
    if (channelData != null) {
      return channelData!.channelCategories[channelCategory] ?? 'Bilinmeyen';
    }
    // Fallback değerler
    switch (channelCategory) {
      case 1: return 'Akarsu';
      case 2: return 'Göl';
      case 3: return 'Baraj';
      case 4: return 'Kuyu';
      case 5: return 'Sulama Kanalı';
      case 6: return 'Meteoroloji İstasyonu';
      case 7: return 'Su Kalitesi';
      default: return 'Bilinmeyen';
    }
  }

  String get subCategory {
    if (channelData != null) {
      return channelData!.channelSubCategories[channelSubCategory] ?? 'Bilinmeyen';
    }
    // Fallback değerler
    switch (channelSubCategory) {
      case 1: return 'Alt Kategori Yok';
      case 2: return 'Ana Cebri Boru';
      case 3: return 'Tarımsal Sulama';
      case 4: return 'Sağ Sahil Sulama';
      case 5: return 'Sol Sahil Sulama';
      case 6: return 'Dereye Deşarj';
      case 7: return 'İçme Suyu';
      case 8: return 'Termik Santral';
      default: return 'Bilinmeyen';
    }
  }

  String get parameter {
    if (channelData != null) {
      return channelData!.channelParameters[channelParameter] ?? 'Bilinmeyen';
    }
    // Fallback değerler
    switch (channelParameter) {
      case 1: return 'Bilinmeyen';
      case 2: return 'Hava Nemi';
      case 3: return 'Hava Basıncı';
      case 4: return 'Hava Sıcaklığı';
      case 5: return 'Doğrudan Radyasyon';
      case 6: return 'Elektriksel İletkenlik';
      case 7: return 'Buharlaşma';
      case 8: return 'Buharlaşma';
      case 9: return 'Global Radyasyon';
      case 10: return 'Yaprak Nemi';
      case 11: return 'pH';
      case 12: return 'Yağış';
      case 13: return 'Güneşlenme Süresi';
      case 14: return 'Toprak Nemi';
      case 15: return 'Kar Kalınlığı';
      case 16: return 'Su Miktarı';
      case 17: return 'Debi';
      case 18: return 'Su Seviyesi';
      case 19: return 'Su Hızı';
      case 20: return 'Su Sıcaklığı';
      default: return 'Bilinmeyen';
    }
  }
}

class VariableData {
  final int channelId;
  final double value;
  final int valueTimestamp;
  final int batteryPercentage;
  final int signalStrength;
  final int valueType;

  VariableData({
    required this.channelId,
    required this.value,
    required this.valueTimestamp,
    required this.batteryPercentage,
    required this.signalStrength,
    required this.valueType,
  });

  factory VariableData.fromJson(Map<String, dynamic> json) {
    return VariableData(
      channelId: json['channel'] ?? 0, // 'channel' alanını kullan
      value: (json['value'] ?? 0.0).toDouble(),
      valueTimestamp: json['value_timestamp'] ?? 0,
      batteryPercentage: json['battery_percentage'] ?? 0,
      signalStrength: json['signal_strength'] ?? 0,
      valueType: json['value_type'] ?? 1,
    );
  }

  String get quality {
    if (signalStrength >= 80) return 'Good';
    if (signalStrength >= 60) return 'Uncertain';
    return 'Bad';
  }

  String get valueTypeName {
    switch (valueType) {
      case 1: return 'Unknown';
      case 2: return 'AVG';
      case 3: return 'INS';
      case 4: return 'MAX';
      case 5: return 'MIN';
      case 6: return 'TOT24H';
      case 7: return 'TOT1H';
      case 8: return 'ENDEX';
      default: return 'Unknown';
    }
  }

  String get formattedTimestamp {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(valueTimestamp * 1000);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
} 