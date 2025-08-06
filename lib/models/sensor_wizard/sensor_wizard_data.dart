import 'sensor.dart';
import 'protocol.dart';

class SensorWizardData {
  final Sensor? selectedSensor;
  final Protocol? selectedProtocol;
  final String? sensorType; // 'analog' veya 'digital'
  final double? minReferenceValue;
  final double? maxReferenceValue;
  final double? offsetValue;
  final SensorParameter? selectedParameter;
  final double? minAlarmValue;
  final double? maxAlarmValue;
  final String? alarmInfo;

  SensorWizardData({
    this.selectedSensor,
    this.selectedProtocol,
    this.sensorType,
    this.minReferenceValue,
    this.maxReferenceValue,
    this.offsetValue,
    this.selectedParameter,
    this.minAlarmValue,
    this.maxAlarmValue,
    this.alarmInfo,
  });

  SensorWizardData copyWith({
    Sensor? selectedSensor,
    Protocol? selectedProtocol,
    String? sensorType,
    double? minReferenceValue,
    double? maxReferenceValue,
    double? offsetValue,
    SensorParameter? selectedParameter,
    double? minAlarmValue,
    double? maxAlarmValue,
    String? alarmInfo,
  }) {
    return SensorWizardData(
      selectedSensor: selectedSensor ?? this.selectedSensor,
      selectedProtocol: selectedProtocol ?? this.selectedProtocol,
      sensorType: sensorType ?? this.sensorType,
      minReferenceValue: minReferenceValue ?? this.minReferenceValue,
      maxReferenceValue: maxReferenceValue ?? this.maxReferenceValue,
      offsetValue: offsetValue ?? this.offsetValue,
      selectedParameter: selectedParameter ?? this.selectedParameter,
      minAlarmValue: minAlarmValue ?? this.minAlarmValue,
      maxAlarmValue: maxAlarmValue ?? this.maxAlarmValue,
      alarmInfo: alarmInfo ?? this.alarmInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSensor': selectedSensor?.toJson(),
      'selectedProtocol': selectedProtocol?.toJson(),
      'sensorType': sensorType,
      'minReferenceValue': minReferenceValue,
      'maxReferenceValue': maxReferenceValue,
      'offsetValue': offsetValue,
      'selectedParameter': selectedParameter?.toJson(),
      'minAlarmValue': minAlarmValue,
      'maxAlarmValue': maxAlarmValue,
      'alarmInfo': alarmInfo,
    };
  }
} 