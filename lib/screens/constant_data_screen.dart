import 'package:flutter/material.dart';
import '../services/constant_data_service.dart';

class ConstantDataScreen extends StatefulWidget {
  const ConstantDataScreen({super.key});

  @override
  State<ConstantDataScreen> createState() => _ConstantDataScreenState();
}

class _ConstantDataScreenState extends State<ConstantDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _constantData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadConstantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConstantData() async {
    try {
      final data = await ConstantDataService.loadConstantData();
      setState(() {
        _constantData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Sabit veriler yüklenirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Sabit Veriler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Kanal Kategorileri'),
            Tab(text: 'Kanal Alt Kategorileri'),
            Tab(text: 'Kanal Parametreleri'),
            Tab(text: 'Ölçüm Birimleri'),
            Tab(text: 'Tag Listesi'),
            Tab(text: 'Değer Tipleri'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sabit veriler yükleniyor...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDataList('Kanal Kategorileri', (_constantData['channel_category']?['channel_category'] as List<dynamic>?) ?? []),
                _buildDataList('Kanal Alt Kategorileri', (_constantData['channel_sub_category']?['channel_sub_category'] as List<dynamic>?) ?? []),
                _buildDataList('Kanal Parametreleri', (_constantData['channel_parameter']?['channel_parameter'] as List<dynamic>?) ?? []),
                _buildDataList('Ölçüm Birimleri', (_constantData['measurement_unit']?['measurement_unit'] as List<dynamic>?) ?? []),
                _buildDataList('Tag Listesi', (_constantData['tag_list']?['tag_list'] as List<dynamic>?) ?? []),
                _buildDataList('Değer Tipleri', (_constantData['value_type']?['value_type'] as List<dynamic>?) ?? []),
              ],
            ),
    );
  }

  Widget _buildDataList(String title, List<dynamic> dataList) {
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
        final item = dataList[index] as Map<String, dynamic>;
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 