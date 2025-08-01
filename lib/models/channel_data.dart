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
    final channelData = constant['channel']?['channel'] as List<dynamic>? ?? [];
    return channelData.map((channel) => Channel.fromJson(channel)).toList();
  }

  List<VariableData> get variableData {
    final data = variable['data']?['data'] as List<dynamic>? ?? [];
    return data.map((item) => VariableData.fromJson(item)).toList();
  }

  int get channelCount => channels.length;
  int get dataCount => variableData.length;
}

class Channel {
  final int id;
  final String name;
  final String description;
  final String unit;
  final String category;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.category,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      unit: json['unit'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class VariableData {
  final int channelId;
  final double value;
  final String timestamp;
  final String quality;

  VariableData({
    required this.channelId,
    required this.value,
    required this.timestamp,
    required this.quality,
  });

  factory VariableData.fromJson(Map<String, dynamic> json) {
    return VariableData(
      channelId: json['channel_id'] ?? 0,
      value: (json['value'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? '',
      quality: json['quality'] ?? '',
    );
  }
} 