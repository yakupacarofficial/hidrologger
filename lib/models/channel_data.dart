import '../services/constant_data_service.dart';

class ChannelData {
  final String timestamp;
  final Map<String, dynamic> variable;

  ChannelData({
    required this.timestamp,
    required this.variable,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    return ChannelData(
      timestamp: json['timestamp'] ?? '',
      variable: json['variable'] ?? {},
    );
  }

  List<Channel> get channels {
    final channelData = variable['channel'] as List<dynamic>? ?? [];
    return channelData.map((channel) => Channel.fromJson(channel, this)).toList();
  }

  List<VariableData> get variableData {
    final data = variable['data'] as List<dynamic>? ?? [];
    return data.map((item) => VariableData.fromJson(item)).toList();
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

  // Sabit verileri ConstantDataService'den alacak getter'lar
  Future<String> get unit async {
    final units = await ConstantDataService.getMeasurementUnits();
    return units[measurementUnit] ?? 'Bilinmeyen';
  }

  Future<String> get category async {
    final categories = await ConstantDataService.getChannelCategories();
    return categories[channelCategory] ?? 'Bilinmeyen';
  }

  Future<String> get subCategory async {
    final subCategories = await ConstantDataService.getChannelSubCategories();
    return subCategories[channelSubCategory] ?? 'Bilinmeyen';
  }

  Future<String> get parameter async {
    final parameters = await ConstantDataService.getChannelParameters();
    return parameters[channelParameter] ?? 'Bilinmeyen';
  }

  Future<String> get station async {
    final stations = await ConstantDataService.getStations();
    return stations[1] ?? 'Bilinmeyen'; // Varsayılan olarak ID 1'i kullan
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