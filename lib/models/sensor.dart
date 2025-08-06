class Sensor {
  final int id;
  final String name;
  final String description;
  final String type; // 'analog' veya 'digital'
  final String? protocol; // Sadece analog sensörler için
  final List<SensorParameter> parameters;

  Sensor({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.protocol,
    required this.parameters,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      protocol: json['protocol'],
      parameters: (json['parameters'] as List)
          .map((param) => SensorParameter.fromJson(param))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'protocol': protocol,
      'parameters': parameters.map((param) => param.toJson()).toList(),
    };
  }
}

class SensorParameter {
  final int id;
  final String name;
  final String unit;
  final double minValue;
  final double maxValue;
  final double offset;

  SensorParameter({
    required this.id,
    required this.name,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    this.offset = 0.0,
  });

  factory SensorParameter.fromJson(Map<String, dynamic> json) {
    return SensorParameter(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      minValue: json['min_value'].toDouble(),
      maxValue: json['max_value'].toDouble(),
      offset: json['offset']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'min_value': minValue,
      'max_value': maxValue,
      'offset': offset,
    };
  }
} 