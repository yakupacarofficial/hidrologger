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
    print('Tarih aralığı değişti: $range');
    print('Eski tarihler: $_startDate - $_endDate');
    print('Yeni tarihler: $start - $end');
    
    setState(() {
      _selectedDateRange = range;
      if (start != null) _startDate = start;
      if (end != null) _endDate = end;
    });
    
    print('State güncellendi. Yeni tarihler: $_startDate - $_endDate');
    _loadLogData();
  }

  Future<void> _loadLogData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // DateTime'i Unix timestamp'e çevir
      final startTimestamp = _startDate.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = _endDate.millisecondsSinceEpoch ~/ 1000;
      
      print('=== LOG VERİSİ YÜKLEME BAŞLADI ===');
      print('Kanal ID: ${widget.channel.id}');
      print('Başlangıç tarihi: $_startDate');
      print('Bitiş tarihi: $_endDate');
      print('Başlangıç timestamp: $startTimestamp');
      print('Bitiş timestamp: $endTimestamp');
      print('Seçilen tarih aralığı: $_selectedDateRange');
      
      // Yeni API çağrısı yap
      final logData = await widget.restfulService.fetchLogs(
        channelId: widget.channel.id,
        startTime: startTimestamp,
        endTime: endTimestamp,
      );

      print('=== API YANITI ALINDI ===');
      print('Log data tipi: ${logData?.runtimeType}');
      print('Log data uzunluğu: ${logData?.length}');
      print('Ham log data: $logData');
      
      if (logData != null && logData.isNotEmpty) {
        print('Log verisi alındı: ${logData.length} kayıt');
        final List<Map<String, dynamic>> formattedData = [];
        
        for (var item in logData) {
          try {
            print('İşlenen item: $item');
            
            // Unix timestamp'i DateTime'e çevir
            final timestamp = DateTime.fromMillisecondsSinceEpoch(
              (item['value_timestamp'] ?? 0) * 1000
            );
            
            final value = (item['value'] ?? 0.0);
            final batteryPercentage = (item['battery_percentage'] ?? 100);
            final signalStrength = (item['signal_strength'] ?? 90);
            
            print('Timestamp: $timestamp, Value: $value, Battery: $batteryPercentage, Signal: $signalStrength');
            
            formattedData.add({
              'id': item['id'] ?? 0,
              'timestamp': timestamp,
              'value': value is num ? value.toDouble() : 0.0,
              'min_value': value is num ? value.toDouble() : 0.0, // API'den gelmiyor, value kullan
              'max_value': value is num ? value.toDouble() : 0.0, // API'den gelmiyor, value kullan
              'quality': 'good', // Varsayılan değer
              'battery_percentage': batteryPercentage,
              'signal_strength': signalStrength,
            });
          } catch (itemError) {
            print('Veri öğesi işlenirken hata: $itemError');
            continue;
          }
        }
        
        // Verileri ID'ye göre sırala (ilk gelen en üstte)
        formattedData.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        
        // Verileri tarihe göre ters sırala (en yeni en üstte)
        formattedData.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        
        setState(() {
          _logData = formattedData;
        });
        
        print('=== FORMATLANMIŞ VERİ ===');
        print('Formatlanmış log verisi: ${formattedData.length} kayıt');
        print('İlk kayıt: ${formattedData.isNotEmpty ? formattedData.first : 'Boş'}');
      } else {
        print('❌ API\'den veri gelmedi veya boş');
        print('Log data null mu: ${logData == null}');
        print('Log data boş mu: ${logData?.isEmpty}');
        setState(() {
          _logData = [];
        });
      }
    } catch (e) {
      print('❌ Log verisi yükleme hatası: $e');
      print('Hata tipi: ${e.runtimeType}');
      print('Hata stack trace: ${e.toString()}');
      setState(() {
        _logData = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('=== LOG VERİSİ YÜKLEME TAMAMLANDI ===');
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
