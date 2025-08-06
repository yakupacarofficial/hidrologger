import 'package:flutter/material.dart';
import 'dart:async';
import '../models/channel_data.dart';
import '../services/restful_service.dart';

class ChannelDetailScreen extends StatefulWidget {
  final Channel channel;
  final VariableData? latestData;
  final RESTfulService restfulService;

  const ChannelDetailScreen({
    super.key,
    required this.channel,
    this.latestData,
    required this.restfulService,
  });

  @override
  State<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends State<ChannelDetailScreen> {
  Channel? _currentChannel;
  VariableData? _currentLatestData;
  StreamSubscription<ChannelData>? _dataSubscription;
  final TextEditingController _logIntervalController = TextEditingController();
  final TextEditingController _offsetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _currentLatestData = widget.latestData;
    _listenToDataUpdates();
    
    // Controller'ları mevcut değerlerle doldur
    _logIntervalController.text = widget.channel.logInterval.toString();
    _offsetController.text = widget.channel.offset.toString();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _logIntervalController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  void _listenToDataUpdates() {
    _dataSubscription = widget.restfulService.dataStream.listen(
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
        });
      },
      onError: (error) {
        // Detay ekranı veri güncelleme hatası
      },
    );
  }

  void _showEditLogIntervalDialog() {
    _logIntervalController.text = _currentChannel!.logInterval.toString();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Aralığını Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kanal: ${_currentChannel!.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: _logIntervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Log Aralığı (saniye)',
                  border: OutlineInputBorder(),
                ),
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
                final newValue = int.tryParse(_logIntervalController.text);
                if (newValue != null && newValue > 0) {
                  _updateChannelField('logInterval', newValue);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geçerli bir sayı giriniz'),
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

  void _showEditOffsetDialog() {
    _offsetController.text = _currentChannel!.offset.toString();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Offset Değerini Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kanal: ${_currentChannel!.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: _offsetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Offset Değeri',
                  border: OutlineInputBorder(),
                ),
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
                final newValue = double.tryParse(_offsetController.text);
                if (newValue != null) {
                  _updateChannelField('offset', newValue);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geçerli bir sayı giriniz'),
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

  void _updateChannelField(String field, dynamic value) async {
    final success = await widget.restfulService.updateChannelField(_currentChannel!.id, field, value);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$field başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$field güncellenirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = _currentChannel ?? widget.channel;
    final latestData = _currentLatestData ?? widget.latestData;
    
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
            _buildInfoRow(context, 'Kanal Adı', channel.name),
            _buildInfoRow(context, 'Açıklama', channel.description),
            _buildAsyncInfoRow(context, 'Ana Kategori', channel.category),
            _buildAsyncInfoRow(context, 'Alt Kategori', channel.subCategory),
            _buildAsyncInfoRow(context, 'Parametre', channel.parameter),
            _buildAsyncInfoRow(context, 'Ölçüm Birimi', channel.unit),
            _buildEditableInfoRow(context, 'Log Aralığı', '${channel.logInterval} saniye', _showEditLogIntervalDialog),
            _buildEditableInfoRow(context, 'Offset Değeri', channel.offset.toString(), _showEditOffsetDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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

  Widget _buildEditableInfoRow(BuildContext context, String label, String value, VoidCallback onEdit) {
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
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEdit,
            tooltip: 'Düzenle',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncInfoRow(BuildContext context, String label, Future<String> valueFuture) {
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
} 