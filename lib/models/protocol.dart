class Protocol {
  final int id;
  final String name;
  final String description;
  final String type; // 'current' veya 'voltage'
  final double minValue;
  final double maxValue;
  final String unit;

  Protocol({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.minValue,
    required this.maxValue,
    required this.unit,
  });

  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      minValue: json['min_value'].toDouble(),
      maxValue: json['max_value'].toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'min_value': minValue,
      'max_value': maxValue,
      'unit': unit,
    };
  }
} 