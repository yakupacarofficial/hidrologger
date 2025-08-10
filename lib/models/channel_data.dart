import '../services/constant_data_service.dart';

class ChannelData {
  final String timestamp;
  final Map<String, dynamic> variable;
  final Map<String, dynamic> alarm;

  ChannelData({
    required this.timestamp,
    required this.variable,
    required this.alarm,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    return ChannelData(
      timestamp: json['timestamp'] ?? '',
      variable: json['variable'] ?? {},
      alarm: json['alarm'] ?? {},
    );
  }

  List<Channel> get channels {
    final channelData = variable['channel'];
    if (channelData == null) return [];
    if (channelData is List<dynamic>) {
      return channelData.map((channel) => Channel.fromJson(channel, this)).toList();
    }
    return [];
  }

  List<VariableData> get variableData {
    final data = variable['data'];
    if (data == null) return [];
    if (data is List<dynamic>) {
      return data.map((item) => VariableData.fromJson(item)).toList();
    }
    return [];
  }

  // Alarm verilerini al
  Map<String, AlarmParameter> get alarmParameters {
    final alarmData = alarm;
    if (alarmData == null || alarmData is! Map<String, dynamic>) {
      return {};
    }
    
    final result = <String, AlarmParameter>{};
    
    alarmData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = AlarmParameter.fromJson(value);
      }
    });
    
    return result;
  }

  // Belirli bir kanalın alarm verilerini al
  AlarmParameter? getChannelAlarm(int channelId) {
    final parameterKey = 'parameter$channelId';
    return alarmParameters[parameterKey];
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
  final double minValue;
  final double maxValue;
  final int valueTimestamp;
  final int batteryPercentage;
  final int signalStrength;
  final int valueType;

  VariableData({
    required this.channelId,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.valueTimestamp,
    required this.batteryPercentage,
    required this.signalStrength,
    required this.valueType,
  });

  factory VariableData.fromJson(Map<String, dynamic> json) {
    return VariableData(
      channelId: json['channel'] ?? 0, // 'channel' alanını kullan
      value: (json['value'] ?? 0.0).toDouble(),
      minValue: (json['min_value'] ?? 0.0).toDouble(),
      maxValue: (json['max_value'] ?? 0.0).toDouble(),
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

class AlarmParameter {
  final int channelId;
  final String alarmInfo;
  final List<Alarm> alarms;

  AlarmParameter({
    required this.channelId,
    required this.alarmInfo,
    required this.alarms,
  });

  factory AlarmParameter.fromJson(Map<String, dynamic> json) {
    final alarmsList = json['alarms'] as List<dynamic>? ?? [];
    return AlarmParameter(
      channelId: json['channel_id'] ?? 0,
      alarmInfo: json['alarminfo'] ?? '',
      alarms: alarmsList.map((item) => Alarm.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'alarminfo': alarmInfo,
      'alarms': alarms.map((alarm) => alarm.toJson()).toList(),
    };
  }
}

class Alarm {
  final double minValue;
  final double maxValue;
  final String color;
  final int dataPostFrequency;

  Alarm({
    required this.minValue,
    required this.maxValue,
    required this.color,
    required this.dataPostFrequency,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      minValue: (json['min_value'] ?? 0.0).toDouble(),
      maxValue: (json['max_value'] ?? 0.0).toDouble(),
      color: json['color'] ?? '#FF0000',
      dataPostFrequency: json['data_post_frequency'] ?? 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_value': minValue,
      'max_value': maxValue,
      'color': color,
      'data_post_frequency': dataPostFrequency,
    };
  }
} 