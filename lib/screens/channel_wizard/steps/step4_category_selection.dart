import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';

class Step4CategorySelection extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4CategorySelection({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step4CategorySelection> createState() => _Step4CategorySelectionState();
}

class _Step4CategorySelectionState extends State<Step4CategorySelection> {
  String _selectedCategory = '';
  final List<String> _categories = [
    'Akarsu',
    'Göl',
    'Deniz',
    'Kuyu',
    'Arıtma Tesisi',
    'Endüstriyel',
    'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.wizardData.selectedCategory;
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    widget.wizardData.selectedCategory = category;
  }

  void _saveAndNext() {
    if (widget.wizardData.isStep4Valid) {
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kategori seçin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kanalınızın hangi kategoride olduğunu seçin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Kategori Seçenekleri
          ..._categories.map((category) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) => _selectCategory(value!),
              secondary: Icon(_getCategoryIcon(category), color: Colors.green),
            ),
          )),
          
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Akarsu': return Icons.water;
      case 'Göl': return Icons.water_drop;
      case 'Deniz': return Icons.beach_access;
      case 'Kuyu': return Icons.water_drop;
      case 'Arıtma Tesisi': return Icons.cleaning_services;
      case 'Endüstriyel': return Icons.factory;
      case 'Diğer': return Icons.more_horiz;
      default: return Icons.category;
    }
  }
}
