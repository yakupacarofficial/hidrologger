import 'package:flutter/material.dart';
import '../services/restful_service.dart';

class StationDetailScreen extends StatefulWidget {
  final RESTfulService restfulService;

  const StationDetailScreen({
    super.key,
    required this.restfulService,
  });

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  Map<String, dynamic>? _stationInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStationInfo();
  }

  Future<void> _loadStationInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stationInfo = await widget.restfulService.fetchStationById(1);
      
      if (mounted) {
        setState(() {
          _stationInfo = stationInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('İstasyon Detayları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadStationInfo,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('İstasyon bilgileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Hata oluştu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStationInfo,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_stationInfo == null) {
      return const Center(
        child: Text('İstasyon bilgisi bulunamadı'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstasyon Başlığı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stationInfo!['name'] ?? 'İsim Yok',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kod: ${_stationInfo!['code'] ?? 'Kod Yok'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // İstasyon Bilgileri
          Text(
            'İstasyon Bilgileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard([
            _buildInfoRow('İstasyon Adı', _stationInfo!['name'] ?? '--'),
            _buildInfoRow('İstasyon Kodu', _stationInfo!['code'] ?? '--'),
            _buildInfoRow('Güvenlik Kodu', _stationInfo!['security_code'] ?? '--'),
            _buildInfoRow('Bölge', '${_stationInfo!['region'] ?? '--'}'),
            _buildInfoRow('Havza', '${_stationInfo!['basin'] ?? '--'}'),
            _buildInfoRow('İstasyon No', '${_stationInfo!['no'] ?? '--'}'),
            _buildInfoRow('Telefon', _stationInfo!['phone'] ?? '--'),
          ]),
          
          const SizedBox(height: 24),
          
          // Konum Bilgileri
          Text(
            'Konum Bilgileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard([
            _buildInfoRow('Enlem', '${_stationInfo!['latitude'] ?? '--'}°'),
            _buildInfoRow('Boylam', '${_stationInfo!['longitude'] ?? '--'}°'),
          ]),
          
          const SizedBox(height: 24),
          
          // Harita Önizleme (Basit)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Harita Önizleme',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enlem: ${_stationInfo!['latitude'] ?? '--'}°, Boylam: ${_stationInfo!['longitude'] ?? '--'}°',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
