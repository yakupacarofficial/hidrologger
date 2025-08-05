import 'dart:async';
import 'package:flutter/material.dart';
import '../models/channel_data.dart';
import '../services/websocket_service.dart';

class AlarmManagementScreen extends StatefulWidget {
  final Channel? channel; // Tek kanal için alarm ekleme
  final WebSocketService webSocketService;

  const AlarmManagementScreen({
    super.key,
    this.channel,
    required this.webSocketService,
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
    _dataSubscription = widget.webSocketService.dataStream.listen(
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

  void _loadAlarmData() {
    // Alarm verilerini sunucudan al
    final message = {
      'command': 'get_alarm',
    };
    widget.webSocketService.sendMessage(message);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

  void _saveAlarmData(Alarm newAlarm) {
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
    
    // Sunucuya gönder
    final message = {
      'command': 'save_alarm',
      'alarm_data': _convertToJson(updatedAlarmData),
    };
    
    widget.webSocketService.sendMessage(message);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm başarıyla eklendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Map<String, dynamic> _convertToJson(Map<String, AlarmParameter> alarmParameters) {
    final result = <String, dynamic>{};
    alarmParameters.forEach((key, value) {
      result[key] = value.toJson();
    });
    return result;
  }

  void _deleteAlarm(String parameterKey, int alarmIndex) {
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
    
    final message = {
      'command': 'save_alarm',
      'alarm_data': _convertToJson(updatedAlarmData),
    };
    
    widget.webSocketService.sendMessage(message);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm silindi'),
        backgroundColor: Colors.orange,
      ),
    );
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
                  if (widget.channel != null) ...[
                    // Kanal Bilgileri Kartı
                    _buildChannelInfoCard(),
                    const SizedBox(height: 20),
                    
                    // Alarm Ekleme Formu
                    _buildAlarmForm(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Tüm Alarmlar Listesi
                  _buildAllAlarmsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildChannelInfoCard() {
    final channel = widget.channel!;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Kanal Bilgileri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Kanal ID', '#${channel.id}'),
            _buildInfoRow('Kanal Adı', channel.name),
            _buildInfoRow('Açıklama', channel.description),
            _buildAsyncInfoRow('Ana Kategori', channel.category),
            _buildAsyncInfoRow('Alt Kategori', channel.subCategory),
            _buildAsyncInfoRow('Parametre', channel.parameter),
            _buildAsyncInfoRow('Ölçüm Birimi', channel.unit),
            _buildInfoRow('Log Aralığı', '${channel.logInterval} saniye'),
            _buildInfoRow('Offset Değeri', channel.offset.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmForm() {
    final channel = widget.channel!;
    final parameterKey = 'parameter${channel.id}';
    final currentAlarmData = _alarmParameters[parameterKey];
    
    // DataPostFrequency controller'ını mevcut değerle doldur
    if (_dataPostFrequencyController.text.isEmpty && currentAlarmData != null) {
      _dataPostFrequencyController.text = currentAlarmData.dataPostFrequency.toString();
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.alarm_add,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Yeni Alarm Ekle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Data Post Frequency
            TextField(
              controller: _dataPostFrequencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Data Post Frequency (ms)',
                border: OutlineInputBorder(),
                helperText: 'Veri gönderme sıklığı',
              ),
            ),
            const SizedBox(height: 16),
            
            // Min ve Max değerler
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minValueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Minimum Değer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxValueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Maksimum Değer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Renk seçici
            Text(
              'Alarm Rengi',
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
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Ekle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addAlarm,
                icon: const Icon(Icons.add),
                label: const Text('Alarm Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAlarmsList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.alarm,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tüm Alarmlar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_alarmParameters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Henüz alarm eklenmemiş',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._alarmParameters.entries.map((entry) {
                final parameterKey = entry.key;
                final alarmParameter = entry.value;
                final channel = _currentData?.channels
                    .firstWhere((ch) => ch.id == alarmParameter.channelId);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kanal: ${channel?.name ?? 'Bilinmeyen'} (ID: ${alarmParameter.channelId})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data Post Frequency: ${alarmParameter.dataPostFrequency} ms',
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
                            color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(alarm.color.replaceAll('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${alarm.minValue} - ${alarm.maxValue}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAlarm(parameterKey, index),
                                tooltip: 'Alarmı Sil',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    
                    const Divider(height: 32),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncInfoRow(String label, Future<String> valueFuture) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: FutureBuilder<String>(
              future: valueFuture,
              builder: (context, snapshot) {
                final value = snapshot.data ?? 'Yükleniyor...';
                return Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 