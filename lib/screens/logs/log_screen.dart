import 'package:flutter/material.dart';
import '../../models/channel_data.dart';
import '../../services/restful_service.dart';
import 'date_selection_widget.dart';
import 'log_chart_widget.dart';
import 'log_table_widget.dart';

class LogScreen extends StatefulWidget {
  final Channel channel;
  final RESTfulService restfulService;

  const LogScreen({
    super.key,
    required this.channel,
    required this.restfulService,
  });

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now();
  String _selectedDateRange = 'Son 24 Saat';
  List<Map<String, dynamic>> _logData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDateRange();
    _loadLogData();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 1));
      _endDate = now;
      _selectedDateRange = 'Son 24 Saat';
    });
  }

  void _onDateRangeChanged(String range, DateTime? start, DateTime? end) {
    setState(() {
      _selectedDateRange = range;
      if (start != null) _startDate = start;
      if (end != null) _endDate = end;
    });
    _loadLogData();
  }

  Future<void> _loadLogData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tarih formatını ISO 8601'e çevir
      final startDateStr = _startDate.toIso8601String();
      final endDateStr = _endDate.toIso8601String();
      
      print('Log verisi isteniyor: Kanal ${widget.channel.id}, Başlangıç: $startDateStr, Bitiş: $endDateStr');
      
      // Gerçek API çağrısı yap
      final logData = await widget.restfulService.fetchLogData(
        widget.channel.id,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      print('Log data tipi: ${logData?.runtimeType}');
      print('Log data success değeri: ${logData?['success']}');
      print('Log data success tipi: ${logData?['success']?.runtimeType}');
      
      if (logData != null && logData['success'] == true) {
        print('Log verisi alındı: $logData');
        final List<Map<String, dynamic>> formattedData = [];
        
        // API response yapısını kontrol et
        print('Log data yapısı: ${logData.keys}');
        print('Data key içeriği: ${logData['data']}');
        
        final dataList = logData['data']?['data'] as List<dynamic>? ?? [];
        
        print('API\'den gelen data listesi: $dataList');
        print('Data listesi uzunluğu: ${dataList.length}');
        
        for (var item in dataList) {
          try {
            print('İşlenen item: $item');
            final timestamp = DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
            final value = (item['value'] ?? 0.0);
            final minValue = (item['min_value'] ?? value);
            final maxValue = (item['max_value'] ?? value);
            
            print('Timestamp: $timestamp, Value: $value, Min: $minValue, Max: $maxValue');
            
            formattedData.add({
              'id': item['id'] ?? 0,
              'timestamp': timestamp,
              'value': value is num ? value.toDouble() : 0.0,
              'min_value': minValue is num ? minValue.toDouble() : 0.0,
              'max_value': maxValue is num ? maxValue.toDouble() : 0.0,
              'quality': 'good', // Varsayılan değer
              'battery_percentage': 100, // Varsayılan değer
              'signal_strength': 100, // Varsayılan değer
            });
          } catch (itemError) {
            print('Veri öğesi işlenirken hata: $itemError');
            continue;
          }
        }
        
        setState(() {
          _logData = formattedData;
        });
        
        print('Formatlanmış log verisi: ${formattedData.length} kayıt');
      } else {
        print('API\'den veri gelmedi veya başarısız');
        print('Log data: $logData');
        setState(() {
          _logData = [];
        });
      }
    } catch (e) {
      print('Log verisi yükleme hatası: $e');
      setState(() {
        _logData = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          '${widget.channel.name} - Log Kayıtları',
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tarih Seçimi
            DateSelectionWidget(
              selectedRange: _selectedDateRange,
              startDate: _startDate,
              endDate: _endDate,
              onDateRangeChanged: _onDateRangeChanged,
            ),
            
            // İçerik
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Seçilen tarih aralığında log verisi bulunamadı',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Farklı bir tarih aralığı seçin veya daha sonra tekrar deneyin',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Grafik
                              LogChartWidget(
                                logData: _logData,
                                channelName: widget.channel.name,
                              ),
                              const SizedBox(height: 24),
                              
                              // Tablo
                              LogTableWidget(logData: _logData),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
