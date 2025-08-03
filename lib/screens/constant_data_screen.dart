import 'package:flutter/material.dart';
import '../services/constant_data_service.dart';
import '../models/channel_data.dart';

class ConstantDataScreen extends StatefulWidget {
  final ChannelData channelData;

  const ConstantDataScreen({
    super.key,
    required this.channelData,
  });

  @override
  State<ConstantDataScreen> createState() => _ConstantDataScreenState();
}

class _ConstantDataScreenState extends State<ConstantDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConstantDataService _constantService = ConstantDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Constant Verileri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Kategoriler'),
            Tab(text: 'Alt Kategoriler'),
            Tab(text: 'Parametreler'),
            Tab(text: 'Kanallar'),
            Tab(text: 'Birimler'),
            Tab(text: 'İstasyonlar'),
            Tab(text: 'Değer Tipleri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDataList('Kanal Kategorileri', _constantService.getChannelCategories(widget.channelData.constant)),
          _buildDataList('Kanal Alt Kategorileri', _constantService.getChannelSubCategories(widget.channelData.constant)),
          _buildDataList('Kanal Parametreleri', _constantService.getChannelParameters(widget.channelData.constant)),
          _buildDataList('Kanallar', _constantService.getChannels(widget.channelData.constant)),
          _buildDataList('Ölçüm Birimleri', _constantService.getMeasurementUnits(widget.channelData.constant)),
          _buildDataList('İstasyonlar', _constantService.getStations(widget.channelData.constant)),
          _buildDataList('Değer Tipleri', _constantService.getValueTypes(widget.channelData.constant)),
        ],
      ),
    );
  }

  Widget _buildDataList(String title, List<Map<String, dynamic>> dataList) {
    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.data_usage,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Veri bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$title için veri mevcut değil',
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
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
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
                        child: Text(
                          'ID: ${item['id'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'İsimsiz',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item['description'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Ek alanları göster
                  if (item.length > 3) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: item.entries
                          .where((entry) => 
                              entry.key != 'id' && 
                              entry.key != 'name' && 
                              entry.key != 'description')
                          .map((entry) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 