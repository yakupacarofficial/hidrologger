import 'package:flutter/material.dart';
import '../models/channel_data.dart';
import '../services/websocket_service.dart';
import '../widgets/info_card.dart';
import '../widgets/data_item.dart';
import '../widgets/connection_status_badge.dart';
import 'channel_detail_screen.dart';

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
} 