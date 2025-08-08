import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step2SensorSelection extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2SensorSelection({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2SensorSelection> createState() => _Step2SensorSelectionState();
}

class _Step2SensorSelectionState extends State<Step2SensorSelection> {
  String _selectedSensor = 'TPEC 3 Parametreli Sensör';

  @override
  void initState() {
    super.initState();
    _selectedSensor = widget.wizardData.selectedSensor;
  }

  void _selectSensor(String sensor) {
    setState(() {
      _selectedSensor = sensor;
    });
    widget.wizardData.selectedSensor = sensor;
  }

  void _saveAndNext() {
    if (widget.wizardData.isStep2Valid) {
      widget.onNext();
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
            'Sensör Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kullanmak istediğiniz sensörü seçin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sensör Seçenekleri
          Card(
            child: ListTile(
              leading: const Icon(Icons.sensors, size: 32, color: Colors.blue),
              title: const Text(
                'TPEC 3 Parametreli Sensör',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Su sıcaklığı, basınç ve elektriksel iletkenlik ölçümü',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Radio<String>(
                value: 'TPEC 3 Parametreli Sensör',
                groupValue: _selectedSensor,
                onChanged: (value) => _selectSensor(value!),
              ),
              onTap: () => _selectSensor('TPEC 3 Parametreli Sensör'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sensör Açıklaması
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Sensör Özellikleri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Su Sıcaklığı (WAT): -5°C ile +50°C arası\n'
                  '• Su Basıncı (WAP): 0-10 bar arası\n'
                  '• Elektriksel İletkenlik (EC): 0-2000 μS/cm arası\n'
                  '• Hassasiyet: ±0.1°C, ±0.01 bar, ±1 μS/cm',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          
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
}
