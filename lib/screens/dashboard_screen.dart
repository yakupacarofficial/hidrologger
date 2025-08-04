import 'package:flutter/material.dart';
import '../models/channel_data.dart';
import '../services/websocket_service.dart';
import '../widgets/info_card.dart';
import '../widgets/data_item.dart';
import '../widgets/connection_status_badge.dart';
import 'channel_detail_screen.dart';
import 'constant_data_screen.dart';

class DashboardScreen extends StatefulWidget {
  final WebSocketService webSocketService;

  const DashboardScreen({
    super.key,
    required this.webSocketService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChannelData? _currentData;
  String _connectionStatus = 'Bağlanıyor...';
  bool _isConnected = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenToData();
  }

  void _listenToData() {
    widget.webSocketService.dataStream.listen(
      (data) {
        setState(() {
          _currentData = data;
          _isConnected = true;
          _connectionStatus = 'Bağlı';
        });
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Bağlantı Hatası';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri alma hatası: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onDone: () {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Bağlantı Kesildi';
        });
      },
    );
  }

  @override
  void dispose() {
    widget.webSocketService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('HIDROLOGGER Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _currentData != null ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ConstantDataScreen(
                    channelData: _currentData!,
                  ),
                ),
              );
            } : null,
            tooltip: 'Constant Verileri',
          ),
          ConnectionStatusBadge(
            isConnected: _isConnected,
            status: _connectionStatus,
          ),
        ],
      ),
      body: Column(
        children: [
          // Üst Bilgi Kartları
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: 'Kanal Sayısı',
                    value: '${_currentData?.channelCount ?? 0}',
                    icon: Icons.sensors,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    title: 'Veri Sayısı',
                    value: '${_currentData?.dataCount ?? 0}',
                    icon: Icons.data_usage,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    title: 'Son Güncelleme',
                    value: _currentData?.timestamp != null 
                        ? _formatTimestamp(_currentData!.timestamp)
                        : '--',
                    icon: Icons.access_time,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Arama Kutusu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Kanal ismine göre ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Kanal Verileri Başlığı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.list, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Kanal Verileri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Arama: "$_searchQuery"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Kanal Verileri Listesi
          Expanded(
            child: _currentData == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Veriler yükleniyor...'),
                      ],
                    ),
                  )
                : _buildChannelDataList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelDataList() {
    final channels = _currentData!.channels;
    final variableData = _currentData!.variableData;
    
    // Arama filtresi uygula
    final filteredChannels = _searchQuery.isEmpty
        ? channels
        : channels.where((channel) =>
            channel.name.toLowerCase().contains(_searchQuery) ||
            channel.description.toLowerCase().contains(_searchQuery)
          ).toList();

    if (channels.isEmpty) {
      return const Center(
        child: Text('Kanal verisi bulunamadı'),
      );
    }
    
    if (_searchQuery.isNotEmpty && filteredChannels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '"$_searchQuery" için sonuç bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı bir arama terimi deneyin',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredChannels.length,
      itemBuilder: (context, index) {
        final channel = filteredChannels[index];
        final data = variableData.where((d) => d.channelId == channel.id).toList();
        final latestData = data.isNotEmpty ? data.first : null;
        final allData = data.isNotEmpty ? data : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChannelDetailScreen(
                    channel: channel,
                    latestData: latestData,
                    allData: allData,
                    webSocketService: widget.webSocketService,
                  ),
                ),
              );
            },
            onLongPress: () {
              _showAlarmOptions(context, channel, latestData);
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                channel.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            channel.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (latestData != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DataItem(
                              label: 'Mevcut Değer',
                              value: '${latestData.value.toStringAsFixed(2)} ${channel.unit}',
                              icon: Icons.show_chart,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DataItem(
                              label: 'Kalite',
                              value: '${latestData.quality} (${latestData.signalStrength}%)',
                              icon: Icons.check_circle,
                              color: _getQualityColor(latestData.quality),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DataItem(
                              label: 'Değer Tipi',
                              value: latestData.valueTypeName,
                              icon: Icons.category,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DataItem(
                              label: 'Batarya',
                              value: '${latestData.batteryPercentage}%',
                              icon: Icons.battery_full,
                              color: _getBatteryColor(latestData.batteryPercentage),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Son Güncelleme: ${latestData.formattedTimestamp}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Veri bulunamadı',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'bad':
        return Colors.red;
      case 'uncertain':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 20) return Colors.red;
    return Colors.red.shade900;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  void _showAlarmOptions(BuildContext context, Channel channel, VariableData? latestData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                '${channel.name} - Alarm Ayarları',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Alarm Ekle butonu
              ListTile(
                leading: Icon(
                  Icons.add_alert,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Alarm Ekle'),
                subtitle: const Text('Bu kanal için alarm ayarları oluştur'),
                onTap: () {
                  Navigator.pop(context);
                  _showAlarmDialog(context, channel, latestData);
                },
              ),
              
              // Mevcut alarm durumu
              if (latestData != null) ...[
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('Mevcut Değer'),
                  subtitle: Text('${latestData.value.toStringAsFixed(2)} ${channel.unit}'),
                ),
              ],
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAlarmDialog(BuildContext context, Channel channel, VariableData? latestData) {
    // Alarm verilerini hazırla
    final alarmData = _prepareAlarmData(channel, latestData);
    
    // Controller'ları oluştur
    final istCodeController = TextEditingController(text: alarmData['istCode'] ?? '');
    final securityCodeController = TextEditingController(text: alarmData['securityCode'] ?? '');
    final dataPostFrequencyController = TextEditingController(text: (alarmData['dataPostFrequency'] ?? 60).toString());
    final yellowAlertValueController = TextEditingController(text: (alarmData['yellowAlert']?[0] ?? 50).toString());
    final yellowAlertTimeController = TextEditingController(text: (alarmData['yellowAlert']?[1] ?? 10).toString());
    final orangeAlertValueController = TextEditingController(text: (alarmData['orangeAlert']?[0] ?? 55).toString());
    final orangeAlertTimeController = TextEditingController(text: (alarmData['orangeAlert']?[1] ?? 5).toString());
    final redAlertValueController = TextEditingController(text: (alarmData['redAlert']?[0] ?? 70).toString());
    final redAlertTimeController = TextEditingController(text: (alarmData['redAlert']?[1] ?? 1).toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${channel.name} - Alarm Ayarları'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İstasyon Kodu
                TextField(
                  controller: istCodeController,
                  decoration: const InputDecoration(
                    labelText: 'İstasyon Kodu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Güvenlik Kodu
                TextField(
                  controller: securityCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Güvenlik Kodu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Parametre ID (Salt okunur)
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Parametre ID',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  controller: TextEditingController(text: alarmData['parameter']?.toString() ?? ''),
                ),
                const SizedBox(height: 12),
                
                // Veri Gönderme Sıklığı
                TextField(
                  controller: dataPostFrequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Veri Gönderme Sıklığı (saniye)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Alarm Seviyeleri
                const Text(
                  'Alarm Seviyeleri:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                
                // Sarı Uyarı
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yellowAlertValueController,
                        decoration: const InputDecoration(
                          labelText: 'Sarı Uyarı Değeri',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yellowAlertTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Süre (sn)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Turuncu Uyarı
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: orangeAlertValueController,
                        decoration: const InputDecoration(
                          labelText: 'Turuncu Uyarı Değeri',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: orangeAlertTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Süre (sn)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Kırmızı Uyarı
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: redAlertValueController,
                        decoration: const InputDecoration(
                          labelText: 'Kırmızı Uyarı Değeri',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: redAlertTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Süre (sn)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
                if (latestData != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mevcut değer: ${latestData.value.toStringAsFixed(2)} ${channel.unit}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Güncellenmiş alarm verilerini topla
                final updatedAlarmData = {
                  'istCode': istCodeController.text.trim(),
                  'securityCode': securityCodeController.text.trim(),
                  'parameter': alarmData['parameter'],
                  'deviceSettings': {
                    'dataPostFrequency': int.tryParse(dataPostFrequencyController.text.trim()) ?? 60,
                    'yellowAlert': [
                      int.tryParse(yellowAlertValueController.text.trim()) ?? 50,
                      int.tryParse(yellowAlertTimeController.text.trim()) ?? 10,
                    ],
                    'orangeAlert': [
                      int.tryParse(orangeAlertValueController.text.trim()) ?? 55,
                      int.tryParse(orangeAlertTimeController.text.trim()) ?? 5,
                    ],
                    'redAlert': [
                      int.tryParse(redAlertValueController.text.trim()) ?? 70,
                      int.tryParse(redAlertTimeController.text.trim()) ?? 1,
                    ],
                  }
                };
                
                _saveAlarmData(updatedAlarmData);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${channel.name} için alarm ayarları kaydedildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlarmInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _prepareAlarmData(Channel channel, VariableData? latestData) {
    // Alarm verilerini hazırla
    final alarmData = <String, dynamic>{};
    
    // Tüm verileri alarm.json'dan al
    final alarmJson = _currentData?.rawData['alarm'] as Map<String, dynamic>?;
    
    // İstasyon kodunu alarm.json'dan al
    alarmData['istCode'] = alarmJson?['istCode'] ?? '0606001';
    
    // Güvenlik kodunu alarm.json'dan al
    alarmData['securityCode'] = alarmJson?['securityCode'] ?? '1234567890';
    
    // Parametre ID'sini seçilen kanalın ID'sinden al (alarm.json'daki parameter ile bağdaştır)
    alarmData['parameter'] = channel.id;
    
    // Veri gönderme sıklığını alarm.json'dan al
    final deviceSettings = alarmJson?['deviceSettings'] as Map<String, dynamic>?;
    alarmData['dataPostFrequency'] = deviceSettings?['dataPostFrequency'] ?? 60;
    
    // Alarm seviyelerini alarm.json'dan al
    alarmData['yellowAlert'] = deviceSettings?['yellowAlert'] ?? [50, 10];
    alarmData['orangeAlert'] = deviceSettings?['orangeAlert'] ?? [55, 5];
    alarmData['redAlert'] = deviceSettings?['redAlert'] ?? [70, 1];
    
    return alarmData;
  }

  void _saveAlarmData(Map<String, dynamic> alarmData) async {
    // Alarm verilerini server'a gönder
    final message = {
      'command': 'save_alarm',
      'data': alarmData
    };
    
    try {
      final success = await widget.webSocketService.sendMessage(message);
      if (success) {
        print('Alarm verileri kaydedildi: $alarmData');
      } else {
        print('Alarm kaydetme hatası: ${widget.webSocketService.lastError}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm kaydetme hatası: ${widget.webSocketService.lastError}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Alarm kaydetme exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm kaydetme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 