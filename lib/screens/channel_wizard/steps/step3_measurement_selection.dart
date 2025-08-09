import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step3MeasurementSelection extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3MeasurementSelection({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step3MeasurementSelection> createState() => _Step3MeasurementSelectionState();
}

class _Step3MeasurementSelectionState extends State<Step3MeasurementSelection> {
  final List<String> _availableMeasurements = ['WAT', 'WAP', 'EC'];
  String? _selectedMeasurement;

  @override
  void initState() {
    super.initState();
    // Eğer daha önce seçim yapılmışsa, ilk seçimi al
    if (widget.wizardData.selectedMeasurements.isNotEmpty) {
      _selectedMeasurement = widget.wizardData.selectedMeasurements.first;
    }
  }

  void _selectMeasurement(String measurement) {
    setState(() {
      _selectedMeasurement = measurement;
    });
    widget.wizardData.selectedMeasurements = [_selectedMeasurement!];
  }

  void _saveAndNext() {
    if (widget.wizardData.isStep3Valid) {
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir ölçüm seçin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ölçülecek Değeri Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hangi parametreyi ölçmek istiyorsunuz?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Ölçüm Seçenekleri
          ..._availableMeasurements.map((measurement) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(
                _getMeasurementTitle(measurement),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_getMeasurementDescription(measurement)),
              value: measurement,
              groupValue: _selectedMeasurement,
              onChanged: (value) => _selectMeasurement(value!),
              secondary: Icon(_getMeasurementIcon(measurement), color: Colors.blue),
            ),
          )),
          
          const Spacer(),
          
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

  String _getMeasurementDescription(String measurement) {
    switch (measurement) {
      case 'WAT': return 'Su sıcaklığını ölçer';
      case 'WAP': return 'Su basıncını ölçer';
      case 'EC': return 'Elektriksel iletkenliği ölçer';
      default: return '';
    }
  }

  IconData _getMeasurementIcon(String measurement) {
    switch (measurement) {
      case 'WAT': return Icons.thermostat;
      case 'WAP': return Icons.speed;
      case 'EC': return Icons.electric_bolt;
      default: return Icons.sensors;
    }
  }
}
