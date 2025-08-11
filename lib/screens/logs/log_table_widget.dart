import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> logData;

  const LogTableWidget({
    super.key,
    required this.logData,
  });

  @override
  Widget build(BuildContext context) {
    if (logData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text('Tablo verisi bulunamadı'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          // Tablo başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Log Kayıtları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${logData.length} kayıt',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Tablo başlıkları
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tarih/Saat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Değer',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Kalite',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Batarya',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tablo içeriği
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: logData.length,
              itemBuilder: (context, index) {
                final item = logData[index];
                final timestamp = item['timestamp'] as DateTime? ?? DateTime.now();
                final value = (item['value'] as num?)?.toDouble() ?? 0.0;
                final quality = item['quality'] as String? ?? 'good';
                final batteryPercentage = (item['battery_percentage'] as num?)?.toInt() ?? 100;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: index.isEven 
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tarih/Saat
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('dd.MM.yyyy\nHH:mm:ss').format(timestamp),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      
                      // Değer
                      Expanded(
                        flex: 1,
                        child: Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      // Kalite
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getQualityColor(quality).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getQualityColor(quality),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getQualityText(quality),
                            style: TextStyle(
                              color: _getQualityColor(quality),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      // Batarya
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.battery_full,
                              size: 16,
                              color: _getBatteryColor(batteryPercentage),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$batteryPercentage%',
                              style: TextStyle(
                                color: _getBatteryColor(batteryPercentage),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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

  String _getQualityText(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
        return 'İyi';
      case 'bad':
        return 'Kötü';
      case 'uncertain':
        return 'Belirsiz';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 20) return Colors.red;
    return Colors.red.shade900;
  }
}