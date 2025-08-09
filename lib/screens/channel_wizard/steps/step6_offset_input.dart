import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step6OffsetInput extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step6OffsetInput({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step6OffsetInput> createState() => _Step6OffsetInputState();
}

class _Step6OffsetInputState extends State<Step6OffsetInput> {
  final TextEditingController _offsetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _offsetController.text = widget.wizardData.offsetValue.toString();
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    final offsetValue = double.tryParse(_offsetController.text) ?? 0.0;
    widget.wizardData.offsetValue = offsetValue;
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
            'Offset Değeri',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ölçüm değerlerine uygulanacak offset değerini girin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Offset Açıklaması
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
                      'Offset Nedir?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Offset değeri, sensörden gelen ham veriye eklenen veya çıkarılan sabit bir değerdir. '
                  'Bu, kalibrasyon veya düzeltme amaçlı kullanılır.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Offset Girişi
          TextFormField(
            controller: _offsetController,
            decoration: const InputDecoration(
              labelText: 'Offset Değeri',
              hintText: 'Örn: 0.5 veya -0.2',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_circle_outline),
              suffixText: 'Birim',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Offset değeri girin';
              }
              if (double.tryParse(value) == null) {
                return 'Geçerli bir sayı girin';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Örnek Kullanım
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Örnek Kullanım:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '• Sensör 25.3°C gösteriyor, offset 0.5 ise → 25.8°C kaydedilir\n'
                  '• Sensör 2.1 bar gösteriyor, offset -0.1 ise → 2.0 bar kaydedilir',
                  style: TextStyle(fontSize: 12),
                ),
              ],
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
}
