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
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _minResetController = TextEditingController();
  final TextEditingController _maxResetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Mevcut değerleri yükle
    _minController.text = widget.wizardData.minValue.toString();
    _maxController.text = widget.wizardData.maxValue.toString();
    _minResetController.text = widget.wizardData.minValueReset.toString();
    _maxResetController.text = widget.wizardData.maxValueReset.toString();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _minResetController.dispose();
    _maxResetController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    // Değerleri kaydet
    widget.wizardData.minValue = double.tryParse(_minController.text) ?? -10.0;
    widget.wizardData.maxValue = double.tryParse(_maxController.text) ?? 50.0;
    widget.wizardData.minValueReset = double.tryParse(_minResetController.text) ?? 0.0;
    widget.wizardData.maxValueReset = double.tryParse(_maxResetController.text) ?? 40.0;
    
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMeasurementTitle(widget.wizardData.selectedParameter),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Minimum Alarm
                  Text(
                    'Minimum Alarm',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minController,
                          decoration: InputDecoration(
                            labelText: 'Min Değer',
                            border: const OutlineInputBorder(),
                            suffixText: widget.wizardData.selectedUnit,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _minResetController,
                          decoration: InputDecoration(
                            labelText: 'Reset Değeri',
                            border: const OutlineInputBorder(),
                            suffixText: widget.wizardData.selectedUnit,
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
                          controller: _maxController,
                          decoration: InputDecoration(
                            labelText: 'Max Değer',
                            border: const OutlineInputBorder(),
                            suffixText: widget.wizardData.selectedUnit,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxResetController,
                          decoration: InputDecoration(
                            labelText: 'Reset Değeri',
                            border: const OutlineInputBorder(),
                            suffixText: widget.wizardData.selectedUnit,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
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
      case 'temperature': return 'Sıcaklık';
      case 'humidity': return 'Nem';
      case 'pressure': return 'Basınç';
      case 'conductivity': return 'İletkenlik';
      default: return measurement;
    }
  }
}
