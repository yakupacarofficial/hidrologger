import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> logData;
  final String channelName;

  const LogChartWidget({
    super.key,
    required this.logData,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    if (logData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text('Grafik verisi bulunamadı'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Değer Grafiği',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Toplam ${logData.length} kayıt',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Grafik
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: ChartPainter(logData: logData),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Alt bilgi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son güncelleme: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  channelName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> logData;

  ChartPainter({required this.logData});

  @override
  void paint(Canvas canvas, Size size) {
    if (logData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final values = logData.map((e) => e['value'] as double).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;

    final width = size.width;
    final height = size.height;
    final padding = 20.0;

    fillPath.moveTo(padding, height - padding);

    for (int i = 0; i < values.length; i++) {
      final x = padding + (i / (values.length - 1)) * (width - 2 * padding);
      final normalizedValue = valueRange > 0 
          ? (values[i] - minValue) / valueRange 
          : 0.5;
      final y = height - padding - normalizedValue * (height - 2 * padding);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(width - padding, height - padding);
    fillPath.close();

    // Fill area
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = padding + (i / (values.length - 1)) * (width - 2 * padding);
      final normalizedValue = valueRange > 0 
          ? (values[i] - minValue) / valueRange 
          : 0.5;
      final y = height - padding - normalizedValue * (height - 2 * padding);

      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
