import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step1BasicInfo extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;

  const Step1BasicInfo({
    super.key,
    required this.wizardData,
    required this.onNext,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = const Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.wizardData.channelName;
    _descriptionController.text = widget.wizardData.channelDescription;
    _selectedColor = _hexToColor(widget.wizardData.channelColor);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kanal Rengi Seçin'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _saveAndNext() {
    widget.wizardData.channelName = _nameController.text.trim();
    widget.wizardData.channelDescription = _descriptionController.text.trim();
    widget.wizardData.channelColor = _colorToHex(_selectedColor);
    
    if (widget.wizardData.isStep1Valid) {
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
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
            'Temel Bilgiler',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kanalınız için temel bilgileri girin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Kanal Adı
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Kanal Adı *',
              hintText: 'Örn: Ana Kanal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kanal adı gereklidir';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Kanal Açıklaması
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Kanal Açıklaması *',
              hintText: 'Örn: Ana su kanalı ölçüm noktası',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kanal açıklaması gereklidir';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Kanal Rengi
          InkWell(
            onTap: _showColorPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Kanal Rengi'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // İleri Butonu
          SizedBox(
            width: double.infinity,
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
    );
  }
}
