import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step5UnitSelection extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step5UnitSelection({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step5UnitSelection> createState() => _Step5UnitSelectionState();
}

class _Step5UnitSelectionState extends State<Step5UnitSelection> {
  final Map<String, String> _selectedUnits = {};

  @override
  void initState() {
    super.initState();
    _selectedUnits.addAll(widget.wizardData.selectedUnits);
  }

  void _selectUnit(String measurement, String unit) {
    setState(() {
      _selectedUnits[measurement] = unit;
    });
    widget.wizardData.selectedUnits = Map.from(_selectedUnits);
  }

  void _saveAndNext() {
    if (widget.wizardData.isStep5Valid) {
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm ölçümler için birim seçin'),
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
            'Birim Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Her ölçüm için uygun birimi seçin',
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
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _getUnitsForMeasurement(measurement).map((unit) {
                            final isSelected = _selectedUnits[measurement] == unit;
                            return ChoiceChip(
                              label: Text(unit),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _selectUnit(measurement, unit);
                                }
                              },
                            );
                          }).toList(),
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

  List<String> _getUnitsForMeasurement(String measurement) {
    switch (measurement) {
      case 'WAT': return ['°C', '°F', 'K'];
      case 'WAP': return ['bar', 'psi', 'Pa', 'kPa', 'MPa', 'mmHg', 'atm'];
      case 'EC': return ['μS/cm', 'mS/cm', 'S/cm', 'ppm', 'ppt'];
      default: return [];
    }
  }
}
