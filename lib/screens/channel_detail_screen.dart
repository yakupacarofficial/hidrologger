import 'package:flutter/material.dart';
import 'dart:async';
import '../models/channel_data.dart';
import '../services/websocket_service.dart';

class ChannelDetailScreen extends StatefulWidget {
  final Channel channel;
  final VariableData? latestData;
  final List<VariableData>? allData; // Tüm veri geçmişi için
  final WebSocketService webSocketService;

  const ChannelDetailScreen({
    super.key,
    required this.channel,
    this.latestData,
    this.allData,
    required this.webSocketService,
  });

  @override
  State<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends State<ChannelDetailScreen> {
  Channel? _currentChannel;
  VariableData? _currentLatestData;
  List<VariableData>? _currentAllData;
  StreamSubscription<ChannelData>? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _currentLatestData = widget.latestData;
    _currentAllData = widget.allData;
    _listenToDataUpdates();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _listenToDataUpdates() {
    _dataSubscription = widget.webSocketService.dataStream.listen(
      (channelData) {
        setState(() {
          // Güncel kanal verisini bul
          final updatedChannel = channelData.channels.firstWhere(
            (ch) => ch.id == widget.channel.id,
            orElse: () => widget.channel,
          );
          _currentChannel = updatedChannel;

          // Güncel variable verilerini bul
          final updatedVariableData = channelData.variableData
              .where((data) => data.channelId == widget.channel.id)
              .toList();
          
          if (updatedVariableData.isNotEmpty) {
            _currentLatestData = updatedVariableData.first;
          }
          
          // Geçmiş verileri al
          _currentAllData = channelData.getChannelHistory(widget.channel.id);
        });
      },
      onError: (error) {
        print('Detay ekranı veri güncelleme hatası: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final channel = _currentChannel ?? widget.channel;
    final latestData = _currentLatestData ?? widget.latestData;
    final allData = _currentAllData ?? widget.allData;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          channel.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, size: 20),
            onPressed: () {
              _showAlarmSettings(context);
            },
            tooltip: 'Alarm Ayarları',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () {
              // TODO: Kanal hakkında detay bilgi göster
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kanal Başlık Kartı
              _buildHeaderCard(context),
              const SizedBox(height: 20),
              
              // Veri Kartları
              if (latestData != null) ...[
                _buildDataCards(context, latestData, channel),
                const SizedBox(height: 20),
              ] else ...[
                _buildNoDataCard(context),
                const SizedBox(height: 20),
              ],
              
              // Kanal Bilgileri
              _buildChannelInfoCard(context, channel),
              const SizedBox(height: 20),
              
              // Veri Geçmişi
              if (allData != null && allData!.isNotEmpty) ...[
                _buildDataHistoryCard(context, allData, channel),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Kanal İkonu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getChannelIcon(_currentChannel!),
                size: 48,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Kanal İsmi
            Text(
              _currentChannel!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Kanal Açıklaması
            Text(
              _currentChannel!.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Kategori Etiketi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  FutureBuilder<String>(
                    future: _currentChannel!.category,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Yükleniyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCards(BuildContext context, VariableData latestData, Channel channel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Anlık Veriler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Ana Değer Kartı
        _buildMainValueCard(context, latestData, channel),
        const SizedBox(height: 16),
        
        // Alt Veri Kartları
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Sinyal Kalitesi',
                '${latestData!.quality}',
                '${latestData!.signalStrength}%',
                Icons.signal_cellular_alt,
                _getQualityColor(latestData!.quality),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Batarya Durumu',
                '${latestData!.batteryPercentage}%',
                _getBatteryStatus(latestData!.batteryPercentage),
                Icons.battery_full,
                _getBatteryColor(latestData!.batteryPercentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Değer Tipi',
                latestData!.valueTypeName,
                _getValueTypeDescription(latestData!.valueType),
                Icons.category,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Son Güncelleme',
                latestData!.formattedTimestamp,
                'Gerçek zamanlı',
                Icons.access_time,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainValueCard(BuildContext context, VariableData latestData, Channel channel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 40,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          Text(
            '${latestData!.value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: channel.unit,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Yükleniyor...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Mevcut Değer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Veri Bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu kanal için henüz veri alınmamış',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelInfoCard(BuildContext context, Channel channel) {
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
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
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
            const SizedBox(height: 20),
            _buildInfoRow(context, 'Kanal ID', '#${channel.id}'),
            _buildInfoRow(context, 'Kanal Adı', channel.name, isEditable: true, fieldName: 'name'),
            _buildInfoRow(context, 'Açıklama', channel.description, isEditable: true, fieldName: 'description'),
            _buildAsyncInfoRow(context, 'Ana Kategori', channel.category, isEditable: true, fieldName: 'channelCategory'),
            _buildAsyncInfoRow(context, 'Alt Kategori', channel.subCategory, isEditable: true, fieldName: 'channelSubCategory'),
            _buildAsyncInfoRow(context, 'Parametre', channel.parameter, isEditable: true, fieldName: 'channelParameter'),
            _buildAsyncInfoRow(context, 'Ölçüm Birimi', channel.unit, isEditable: true, fieldName: 'measurementUnit'),
            _buildInfoRow(context, 'Log Aralığı', '${channel.logInterval} saniye', isEditable: true, fieldName: 'logInterval'),
            _buildInfoRow(context, 'Offset Değeri', channel.offset.toString(), isEditable: true, fieldName: 'offset'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isEditable = false, String? fieldName}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: isEditable
                ? GestureDetector(
                    onTap: () {
                      _showEditDialog(context, label, value, fieldName!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
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

  Widget _buildAsyncInfoRow(BuildContext context, String label, Future<String> valueFuture, {bool isEditable = false, String? fieldName}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                return isEditable
                    ? GestureDetector(
                        onTap: () {
                          if (snapshot.hasData) {
                            _showEditDialog(context, label, value, fieldName!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
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

  IconData _getChannelIcon(Channel channel) {
    switch (channel.name.toLowerCase()) {
      case 'seviye':
        return Icons.water_drop;
      case 'sicaklik':
        return Icons.thermostat;
      case 'ec':
        return Icons.electric_bolt;
      default:
        return Icons.sensors;
    }
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

  String _getBatteryStatus(int percentage) {
    if (percentage >= 80) return 'İyi';
    if (percentage >= 50) return 'Orta';
    if (percentage >= 20) return 'Düşük';
    return 'Kritik';
  }

  String _getValueTypeDescription(int valueType) {
    switch (valueType) {
      case 1: return 'Bilinmeyen';
      case 2: return 'Ortalama';
      case 3: return 'Anlık';
      case 4: return 'Maksimum';
      case 5: return 'Minimum';
      case 6: return '24h Toplam';
      case 7: return '1h Toplam';
      case 8: return 'Endex';
      default: return 'Bilinmeyen';
    }
  }



  Widget _buildDataHistoryCard(BuildContext context, List<VariableData> allData, Channel channel) {
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
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
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
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Veri Geçmişi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${allData!.length} kayıt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: allData!.length,
                itemBuilder: (context, index) {
                  final data = allData![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Değer
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Değer',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<String>(
                                future: channel.unit,
                                builder: (context, snapshot) {
                                  return Text(
                                    '${data.value.toStringAsFixed(2)} ${snapshot.data ?? ''}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Değer Tipi
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tip',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.valueTypeName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kalite
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kalite',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getQualityColor(data.quality),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data.quality,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Zaman
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zaman',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.formattedTimestamp,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Batarya
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Batarya',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                _getBatteryIcon(data.batteryPercentage),
                                color: _getBatteryColor(data.batteryPercentage),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBatteryIcon(int percentage) {
    if (percentage >= 80) return Icons.battery_full;
    if (percentage >= 60) return Icons.battery_6_bar;
    if (percentage >= 40) return Icons.battery_4_bar;
    if (percentage >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  void _showEditDialog(BuildContext context, String label, String currentValue, String fieldName) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$label Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty && newValue != currentValue) {
                  _updateChannelField(fieldName, newValue);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _updateChannelField(String fieldName, String newValue) async {
    final channel = _currentChannel ?? widget.channel;
    // WebSocket üzerinden sunucuya güncelleme mesajı gönder
    final updateMessage = {
      'command': 'update_channel',
      'channel_id': channel.id,
      'field': fieldName,
      'value': newValue,
    };
    
    try {
      final success = await widget.webSocketService.sendMessage(updateMessage);
      if (success) {
        print('Kanal güncelleme mesajı gönderildi: $updateMessage');
      } else {
        print('Kanal güncelleme hatası: ${widget.webSocketService.lastError}');
      }
    } catch (e) {
      print('Kanal güncelleme exception: $e');
    }
  }

  void _showAlarmSettings(BuildContext context) {
    final channel = _currentChannel ?? widget.channel;
    final latestData = _currentLatestData ?? widget.latestData;
    
    // Alarm verilerini hazırla
    final alarmData = _prepareAlarmData(channel, latestData);
    
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
                // Veri Gönderme Sıklığı (Düzenlenebilir)
                ListTile(
                  title: const Text('Veri Gönderme Sıklığı'),
                  subtitle: Text('${alarmData['dataPostFrequency']} saniye'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDataPostFrequencyDialog(context, channel);
                    },
                  ),
                ),
                const Divider(),
                
                // Diğer alarm bilgileri (Salt okunur)
                _buildAlarmInfoRow('İstasyon Kodu', alarmData['istCode'] ?? 'N/A'),
                _buildAlarmInfoRow('Güvenlik Kodu', alarmData['securityCode'] ?? 'N/A'),
                _buildAlarmInfoRow('Parametre ID', alarmData['parameter']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                const Text(
                  'Alarm Seviyeleri:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildAlarmInfoRow('Sarı Uyarı', '${alarmData['yellowAlert']?[0]} - ${alarmData['yellowAlert']?[1]} saniye'),
                _buildAlarmInfoRow('Turuncu Uyarı', '${alarmData['orangeAlert']?[0]} - ${alarmData['orangeAlert']?[1]} saniye'),
                _buildAlarmInfoRow('Kırmızı Uyarı', '${alarmData['redAlert']?[0]} - ${alarmData['redAlert']?[1]} saniye'),
                
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
                          child: FutureBuilder<String>(
                            future: channel.unit,
                            builder: (context, snapshot) {
                              return Text(
                                'Mevcut değer: ${latestData.value.toStringAsFixed(2)} ${snapshot.data ?? ''}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
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
              child: const Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveAlarmData(alarmData);
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

  void _showDataPostFrequencyDialog(BuildContext context, Channel channel) {
    final controller = TextEditingController(text: channel.logInterval.toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Veri Gönderme Sıklığı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bu değer alarm ayarlarında kullanılacak ve kanalın veri gönderme sıklığını belirler.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Saniye',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = int.tryParse(controller.text.trim());
                if (newValue != null && newValue > 0) {
                  _updateChannelField('logInterval', newValue.toString());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veri gönderme sıklığı güncellendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geçerli bir sayı girin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    final alarmJson = widget.webSocketService.lastData?.rawData['alarm'] as Map<String, dynamic>?;
    
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