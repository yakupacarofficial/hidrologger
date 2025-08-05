import 'dart:async';
import 'package:flutter/material.dart';
import '../models/channel_data.dart';
import '../services/restful_service.dart';

class AlarmManagementScreen extends StatefulWidget {
  final Channel? channel; // Tek kanal için alarm ekleme
  final RESTfulService restfulService;

  const AlarmManagementScreen({
    super.key,
    this.channel,
    required this.restfulService,
  });

  @override
  State<AlarmManagementScreen> createState() => _AlarmManagementScreenState();
}

class _AlarmManagementScreenState extends State<AlarmManagementScreen> {
  ChannelData? _currentData;
  Map<String, AlarmParameter> _alarmParameters = {};
  bool _isLoading = true;
  StreamSubscription? _dataSubscription;
  
  // Form controllers
  final TextEditingController _dataPostFrequencyController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();
  
  // Color picker
  String _selectedColor = '#FF0000';
  final List<String> _availableColors = [
    '#FF0000', // Kırmızı
    '#00FF00', // Yeşil
    '#0000FF', // Mavi
    '#FFFF00', // Sarı
    '#FF00FF', // Magenta
    '#00FFFF', // Cyan
    '#FFA500', // Turuncu
    '#800080', // Mor
    '#008000', // Koyu Yeşil
    '#FFC0CB', // Pembe
  ];

  @override
  void initState() {
    super.initState();
    _listenToData();
    _loadAlarmData();
    
    // Eğer tek kanal için alarm ekleniyorsa, mevcut dataPostFrequency'i yükle
    if (widget.channel != null) {
      final channelId = widget.channel!.id;
      final parameterKey = 'parameter$channelId';
      
      // Mevcut alarm verilerini kontrol et
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentAlarmData = _alarmParameters[parameterKey];
        if (currentAlarmData != null && mounted) {
          setState(() {
            _dataPostFrequencyController.text = currentAlarmData.dataPostFrequency.toString();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _dataPostFrequencyController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  void _listenToData() {
    _dataSubscription = widget.restfulService.dataStream.listen(
      (data) {
        if (mounted) {
          setState(() {
            _currentData = data;
            _alarmParameters = data.alarmParameters;
          });
        }
      },
      onError: (error) {
        print('Alarm ekranı veri güncelleme hatası: $error');
      },
    );
  }

  void _loadAlarmData() async {
    // Alarm verilerini RESTful API'den al
    final alarmData = await widget.restfulService.fetchAlarmData();
    if (mounted && alarmData != null) {
      setState(() {
        // Alarm verilerini parse et
        final alarmParameters = <String, AlarmParameter>{};
        alarmData.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            alarmParameters[key] = AlarmParameter.fromJson(value);
          }
        });
        _alarmParameters = alarmParameters;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addAlarm() {
    final minValue = double.tryParse(_minValueController.text);
    final maxValue = double.tryParse(_maxValueController.text);
    
    if (minValue == null || maxValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli değerler giriniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (minValue >= maxValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum değer maksimum değerden küçük olmalıdır'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newAlarm = Alarm(
      minValue: minValue,
      maxValue: maxValue,
      color: _selectedColor,
    );

    _saveAlarmData(newAlarm);
    
    // Form'u temizle
    _minValueController.clear();
    _maxValueController.clear();
    _selectedColor = '#FF0000';
  }

  void _saveAlarmData(Alarm newAlarm) async {
    if (widget.channel == null) return;
    
    final channelId = widget.channel!.id;
    final parameterKey = 'parameter$channelId';
    
    // Mevcut alarm verilerini al
    final currentAlarmData = _alarmParameters[parameterKey];
    final dataPostFrequency = int.tryParse(_dataPostFrequencyController.text) ?? 
                             (currentAlarmData?.dataPostFrequency ?? 1000);
    
    // Yeni alarm listesi oluştur
    final updatedAlarms = <Alarm>[...(currentAlarmData?.alarms ?? []), newAlarm];
    
    // Yeni alarm parameter oluştur
    final updatedAlarmParameter = AlarmParameter(
      channelId: channelId,
      dataPostFrequency: dataPostFrequency,
      alarms: updatedAlarms,
    );
    
    // Tüm alarm verilerini güncelle
    final updatedAlarmData = Map<String, AlarmParameter>.from(_alarmParameters);
    updatedAlarmData[parameterKey] = updatedAlarmParameter;
    
    // RESTful API'ye gönder
    final success = await widget.restfulService.saveAlarmData(_convertToJson(updatedAlarmData));
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm eklenirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _convertToJson(Map<String, AlarmParameter> alarmParameters) {
    final result = <String, dynamic>{};
    alarmParameters.forEach((key, value) {
      result[key] = value.toJson();
    });
    return result;
  }

  void _deleteAlarm(String parameterKey, int alarmIndex) async {
    final currentAlarmData = _alarmParameters[parameterKey];
    if (currentAlarmData == null) return;
    
    final updatedAlarms = <Alarm>[...currentAlarmData.alarms];
    updatedAlarms.removeAt(alarmIndex);
    
    final updatedAlarmParameter = AlarmParameter(
      channelId: currentAlarmData.channelId,
      dataPostFrequency: currentAlarmData.dataPostFrequency,
      alarms: updatedAlarms,
    );
    
    final updatedAlarmData = Map<String, AlarmParameter>.from(_alarmParameters);
    updatedAlarmData[parameterKey] = updatedAlarmParameter;
    
    // RESTful API'ye gönder
    final success = await widget.restfulService.saveAlarmData(_convertToJson(updatedAlarmData));
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm silindi'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm silinirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.channel != null 
          ? 'Alarm Ekle: ${widget.channel!.name}'
          : 'Alarm Yönetimi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tek kanal için alarm ekleme formu
                if (widget.channel != null) ...[
                  _buildChannelInfoCard(context),
                  const SizedBox(height: 20),
                  _buildAlarmForm(context),
                  const SizedBox(height: 20),
                ],
                
                // Tüm alarmları listele
                _buildAlarmList(context),
              ],
            ),
          ),
    );
  }

  Widget _buildChannelInfoCard(BuildContext context) {
    final channel = widget.channel!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sensors,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (channel.description.isNotEmpty)
                      Text(
                        channel.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmForm(BuildContext context) {
    final channel = widget.channel!;
    final channelId = channel.id;
    final parameterKey = 'parameter$channelId';
    final currentAlarmData = _alarmParameters[parameterKey];
    
    // DataPostFrequency controller'ı güncelle
    if (_dataPostFrequencyController.text.isEmpty && currentAlarmData != null) {
      _dataPostFrequencyController.text = currentAlarmData.dataPostFrequency.toString();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Alarm Ekle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Data Post Frequency
          TextField(
            controller: _dataPostFrequencyController,
            decoration: const InputDecoration(
              labelText: 'Veri Gönderme Sıklığı (ms)',
              border: OutlineInputBorder(),
              hintText: '1000',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Min/Max Values
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minValueController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Değer',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxValueController,
                  decoration: const InputDecoration(
                    labelText: 'Maksimum Değer',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Color Picker
          Text(
            'Renk Seçin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                      ? Border.all(color: Colors.black, width: 3)
                      : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addAlarm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Alarm Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mevcut Alarmlar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_alarmParameters.isEmpty)
            const Center(
              child: Text(
                'Henüz alarm eklenmemiş',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ..._alarmParameters.entries.map((entry) {
              final parameterKey = entry.key;
              final alarmParameter = entry.value;
              
              // Kanal bilgisini bul
              final channel = _currentData?.channels
                  .firstWhere((c) => c.id == alarmParameter.channelId, 
                             orElse: () => Channel(id: alarmParameter.channelId, name: 'Bilinmeyen Kanal', description: '', channelCategory: 0, channelSubCategory: 0, channelParameter: 0, measurementUnit: 0, logInterval: 0, offset: 0.0));
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     Text(
                     'Kanal: ${channel?.name ?? 'Bilinmeyen Kanal'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Veri Gönderme Sıklığı: ${alarmParameter.dataPostFrequency} ms',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (alarmParameter.alarms.isEmpty)
                    const Text(
                      'Bu kanal için alarm yok',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...alarmParameter.alarms.asMap().entries.map((alarmEntry) {
                      final index = alarmEntry.key;
                      final alarm = alarmEntry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))).withOpacity(0.1),
                          border: Border.all(
                            color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${alarm.minValue} - ${alarm.maxValue}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAlarm(parameterKey, index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }
} 