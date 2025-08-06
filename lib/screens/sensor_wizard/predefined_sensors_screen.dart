import 'package:flutter/material.dart';
import '../../models/sensor_wizard/sensor.dart';
import '../../services/restful_service.dart';
import '../../services/sensor_wizard/sensor_service.dart';
import 'channel_selection_screen.dart';

class PredefinedSensorsScreen extends StatefulWidget {
  final RESTfulService restfulService;

  const PredefinedSensorsScreen({
    super.key,
    required this.restfulService,
  });

  @override
  State<PredefinedSensorsScreen> createState() => _PredefinedSensorsScreenState();
}

class _PredefinedSensorsScreenState extends State<PredefinedSensorsScreen> {
  final SensorService _sensorService = SensorService();
  List<Sensor> _sensors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSensors();
  }

  Future<void> _loadSensors() async {
    try {
      final sensors = await _sensorService.loadSensors();
      setState(() {
        _sensors = sensors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sensörler yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Kayıtlı Sensörler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sensors.isEmpty
              ? _buildEmptyState()
              : _buildSensorsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sensors_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Kayıtlı sensör bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen sensör dosyalarını kontrol edin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensors.length,
      itemBuilder: (context, index) {
        final sensor = _sensors[index];
        return _buildSensorCard(sensor);
      },
    );
  }

  Widget _buildSensorCard(Sensor sensor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showSensorDetails(sensor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getSensorTypeColor(sensor.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sensors,
                      color: _getSensorTypeColor(sensor.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sensor.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip('Tip', sensor.type.toUpperCase()),
                  const SizedBox(width: 8),
                  if (sensor.protocol != null) ...[
                    _buildChip('Protokol', sensor.protocol!),
                    const SizedBox(width: 8),
                  ],
                  _buildChip('Parametre', '${sensor.parameters.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Color _getSensorTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'analog':
        return Colors.blue;
      case 'digital':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showSensorDetails(Sensor sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sensor.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sensör Bilgileri
                    _buildInfoRow('Tip', sensor.type.toUpperCase()),
                    if (sensor.protocol != null)
                      _buildInfoRow('Protokol', sensor.protocol!),
                    _buildInfoRow('Parametre Sayısı', '${sensor.parameters.length}'),
                    
                    const SizedBox(height: 24),
                    
                    // Parametreler
                    Text(
                      'Parametreler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: sensor.parameters.length,
                        itemBuilder: (context, index) {
                          final param = sensor.parameters[index];
                          return _buildParameterCard(param);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Seçim Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _selectSensor(sensor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Bu Sensörü Seç',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(SensorParameter param) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              param.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Birim: ${param.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Text(
                  'Aralık: ${param.minValue} - ${param.maxValue}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectSensor(Sensor sensor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChannelSelectionScreen(
          restfulService: widget.restfulService,
          selectedSensor: sensor,
        ),
      ),
    );
  }
} 