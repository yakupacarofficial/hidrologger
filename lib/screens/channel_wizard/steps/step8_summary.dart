import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';
import '../../../services/restful_service.dart';

class Step8Summary extends StatefulWidget {
  final ChannelWizardData wizardData;
  final RESTfulService restfulService;
  final VoidCallback onBack;

  const Step8Summary({
    super.key,
    required this.wizardData,
    required this.restfulService,
    required this.onBack,
  });

  @override
  State<Step8Summary> createState() => _Step8SummaryState();
}

class _Step8SummaryState extends State<Step8Summary> {
  bool _isSaving = false;

  void _saveChannel() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Kanal verilerini hazırla - Mevcut format
      final channelData = {
        'id': await _getNextChannelId(),
        'name': widget.wizardData.channelName,
        'description': widget.wizardData.channelDescription,
        'channel_category': _getCategoryId(widget.wizardData.selectedCategory),
        'channel_sub_category': _getSubCategoryId(widget.wizardData.selectedCategory),
        'channel_parameter': _getParameterId(widget.wizardData.selectedMeasurements),
        'measurement_unit': _getMeasurementUnitId(widget.wizardData.selectedUnits),
        'value_type': widget.wizardData.selectedMeasurements.length,
        'log_interval': 1000,
        'offset': widget.wizardData.offsetValue,
      };

      // Kanalı kaydet
      final success = await widget.restfulService.createChannel(channelData);
      
      if (success) {
        // Alarm ayarlarını da kaydet
        await _saveAlarmSettings(await _getNextChannelId() - 1);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kanal ve alarm ayarları başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Sihirbazı kapat
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kanal oluşturulurken hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<int> _getNextChannelId() async {
    // Mevcut kanalları al ve en yüksek ID'yi bul
    try {
      final data = await widget.restfulService.fetchAllData();
      final channels = data?.channels ?? [];
      if (channels.isEmpty) return 1;
      
      final maxId = channels.map((c) => c.id).reduce((a, b) => a > b ? a : b);
      return maxId + 1;
    } catch (e) {
      return 1; // Hata durumunda 1'den başla
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
            'Kanal Özeti',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Oluşturacağınız kanalın tüm özelliklerini kontrol edin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Temel Bilgiler
                  _buildSummaryCard(
                    'Temel Bilgiler',
                    [
                      'Kanal Adı: ${widget.wizardData.channelName}',
                      'Açıklama: ${widget.wizardData.channelDescription}',
                      'Renk: ${widget.wizardData.channelColor}',
                    ],
                    Icons.info,
                    Colors.blue,
                  ),
                  
                  // Sensör Bilgileri
                  _buildSummaryCard(
                    'Sensör Bilgileri',
                    [
                      'Sensör: ${widget.wizardData.selectedSensor}',
                      'Kategori: ${widget.wizardData.selectedCategory}',
                    ],
                    Icons.sensors,
                    Colors.green,
                  ),
                  
                  // Ölçüm Bilgileri
                  _buildSummaryCard(
                    'Ölçüm Bilgileri',
                    widget.wizardData.selectedMeasurements.map((measurement) {
                      final unit = widget.wizardData.selectedUnits[measurement] ?? '';
                      return '${_getMeasurementTitle(measurement)}: $unit';
                    }).toList(),
                    Icons.analytics,
                    Colors.orange,
                  ),
                  
                  // Offset
                  _buildSummaryCard(
                    'Offset Değeri',
                    ['Offset: ${widget.wizardData.offsetValue}'],
                    Icons.add_circle_outline,
                    Colors.purple,
                  ),
                  
                  // Alarm Ayarları
                  _buildSummaryCard(
                    'Alarm Ayarları',
                    widget.wizardData.alarmSettings.entries.map((entry) {
                      final measurement = entry.key;
                      final settings = entry.value;
                      return '${_getMeasurementTitle(measurement)}: ${settings['min']} - ${settings['max']}';
                    }).toList(),
                    Icons.alarm,
                    Colors.red,
                  ),
                ],
              ),
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
                  onPressed: _isSaving ? null : _saveChannel,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kanalı Oluştur',
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

  Widget _buildSummaryCard(String title, List<String> items, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
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

  // Helper metodları - Mevcut format için
  int _getCategoryId(String category) {
    switch (category) {
      case 'Akarsu': return 1;
      case 'Göl': return 2;
      case 'Deniz': return 3;
      case 'Kuyu': return 4;
      case 'Arıtma Tesisi': return 5;
      case 'Endüstriyel': return 6;
      case 'Diğer': return 7;
      default: return 1;
    }
  }

  int _getSubCategoryId(String category) {
    switch (category) {
      case 'Akarsu': return 1;
      case 'Göl': return 2;
      case 'Deniz': return 3;
      case 'Kuyu': return 4;
      case 'Arıtma Tesisi': return 5;
      case 'Endüstriyel': return 6;
      case 'Diğer': return 7;
      default: return 1;
    }
  }

  int _getParameterId(List<String> measurements) {
    // Ölçüm sayısına göre parametre ID'si
    if (measurements.contains('WAT') && measurements.contains('WAP') && measurements.contains('EC')) {
      return 3; // 3 parametreli
    } else if (measurements.length == 2) {
      return 2; // 2 parametreli
    } else {
      return 1; // 1 parametreli
    }
  }

  int _getMeasurementUnitId(Map<String, String> units) {
    // İlk birimi baz alarak unit ID'si
    final firstUnit = units.values.firstOrNull;
    switch (firstUnit) {
      case '°C': return 1;
      case 'bar': return 2;
      case 'μS/cm': return 3;
      case 'mS/cm': return 4;
      case 'S/cm': return 5;
      case 'ppm': return 6;
      case 'ppt': return 7;
      case 'psi': return 8;
      case 'Pa': return 9;
      case 'kPa': return 10;
      case 'MPa': return 11;
      case 'mmHg': return 12;
      case 'atm': return 13;
      case '°F': return 14;
      case 'K': return 15;
      default: return 1;
    }
  }

  // Alarm ayarlarını kaydet
  Future<void> _saveAlarmSettings(int channelId) async {
    try {
      final alarmData = {
        'parameter$channelId': {
          'channel_id': channelId,
          'alarminfo': 'Kanal $channelId alarm ayarları',
          'alarms': widget.wizardData.alarmSettings.entries.map((entry) {
            final settings = entry.value;
            return {
              'min_value': settings['min'],
              'max_value': settings['max'],
              'color': '#FF0000',
              'data_post_frequency': 1000,
            };
          }).toList(),
        }
      };

      // Alarm verilerini kaydet
      await widget.restfulService.saveAlarmData(alarmData);
    } catch (e) {
      print('Alarm ayarları kaydedilirken hata: $e');
    }
  }
}
