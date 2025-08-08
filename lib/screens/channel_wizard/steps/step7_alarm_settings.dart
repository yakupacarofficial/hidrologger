import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step7AlarmSettings extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step7AlarmSettings({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step7AlarmSettings> createState() => _Step7AlarmSettingsState();
}

class _Step7AlarmSettingsState extends State<Step7AlarmSettings> {
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (String measurement in widget.wizardData.selectedMeasurements) {
      _controllers[measurement] = {
        'min': TextEditingController(),
        'max': TextEditingController(),
        'minReset': TextEditingController(),
        'maxReset': TextEditingController(),
      };
      
      // Mevcut değerleri yükle
      final alarmData = widget.wizardData.alarmSettings[measurement];
      if (alarmData != null) {
        _controllers[measurement]!['min']!.text = alarmData['min']?.toString() ?? '';
        _controllers[measurement]!['max']!.text = alarmData['max']?.toString() ?? '';
        _controllers[measurement]!['minReset']!.text = alarmData['minReset']?.toString() ?? '';
        _controllers[measurement]!['maxReset']!.text = alarmData['maxReset']?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (var controllers in _controllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _saveAndNext() {
    // Tüm değerleri kaydet
    for (String measurement in widget.wizardData.selectedMeasurements) {
      final controllers = _controllers[measurement]!;
      final alarmData = <String, double>{};
      
      alarmData['min'] = double.tryParse(controllers['min']!.text) ?? 0.0;
      alarmData['max'] = double.tryParse(controllers['max']!.text) ?? 100.0;
      alarmData['minReset'] = double.tryParse(controllers['minReset']!.text) ?? alarmData['min']!;
      alarmData['maxReset'] = double.tryParse(controllers['maxReset']!.text) ?? alarmData['max']!;
      
      widget.wizardData.alarmSettings[measurement] = alarmData;
    }
    
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Ayarları',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Her ölçüm için alarm değerlerini belirleyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: widget.wizardData.selectedMeasurements.map((measurement) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMeasurementTitle(measurement),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Minimum Alarm
                        Text(
                          'Minimum Alarm',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controllers[measurement]!['min']!,
                                decoration: InputDecoration(
                                  labelText: 'Min Değer',
                                  border: const OutlineInputBorder(),
                                  suffixText: widget.wizardData.selectedUnits[measurement] ?? '',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _controllers[measurement]!['minReset']!,
                                decoration: InputDecoration(
                                  labelText: 'Reset Değeri',
                                  border: const OutlineInputBorder(),
                                  suffixText: widget.wizardData.selectedUnits[measurement] ?? '',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Maksimum Alarm
                        Text(
                          'Maksimum Alarm',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controllers[measurement]!['max']!,
                                decoration: InputDecoration(
                                  labelText: 'Max Değer',
                                  border: const OutlineInputBorder(),
                                  suffixText: widget.wizardData.selectedUnits[measurement] ?? '',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _controllers[measurement]!['maxReset']!,
                                decoration: InputDecoration(
                                  labelText: 'Reset Değeri',
                                  border: const OutlineInputBorder(),
                                  suffixText: widget.wizardData.selectedUnits[measurement] ?? '',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Navigasyon Butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Geri'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveAndNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'İleri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMeasurementTitle(String measurement) {
    switch (measurement) {
      case 'WAT': return 'Su Sıcaklığı (WAT)';
      case 'WAP': return 'Su Basıncı (WAP)';
      case 'EC': return 'Elektriksel İletkenlik (EC)';
      default: return measurement;
    }
  }
}
