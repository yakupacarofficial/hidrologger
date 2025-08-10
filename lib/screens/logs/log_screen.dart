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

      if (logData != null) {
        print('Log verisi alındı: $logData');
        final List<Map<String, dynamic>> formattedData = [];
        final dataList = logData['data'] as List<dynamic>? ?? [];
        
        for (var item in dataList) {
          final timestamp = DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
          formattedData.add({
            'id': item['id'] ?? 0,
            'timestamp': timestamp,
            'value': (item['value'] ?? 0.0).toDouble(),
            'min_value': (item['min_value'] ?? 0.0).toDouble(),
            'max_value': (item['max_value'] ?? 0.0).toDouble(),
            'quality': 'good', // Varsayılan değer
            'battery_percentage': 100, // Varsayılan değer
            'signal_strength': 100, // Varsayılan değer
          });
        }
        
        setState(() {
          _logData = formattedData;
        });
        
        print('Formatlanmış log verisi: ${formattedData.length} kayıt');
      } else {
        print('API\'den veri gelmedi, mock data kullanılıyor');
        // API'den veri gelmezse mock data kullan
        _logData = _generateMockData();
      }
    } catch (e) {
      print('Log verisi yükleme hatası: $e');
      // Hata durumunda mock data kullan
      _logData = _generateMockData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateMockData() {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 20; i++) {
      final timestamp = now.subtract(Duration(hours: i));
      data.add({
        'id': i + 1,
        'timestamp': timestamp,
        'value': 20 + (i * 0.5) + (i % 3 == 0 ? 2 : 0),
        'min_value': 18.0 + (i * 0.3),
        'max_value': 22.0 + (i * 0.4),
        'quality': i % 5 == 0 ? 'uncertain' : (i % 7 == 0 ? 'bad' : 'good'),
        'battery_percentage': 100 - (i * 2),
        'signal_strength': 100 - (i * 1.5),
      });
    }
    
    return data.reversed.toList();
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
                      ? const Center(
                          child: Text(
                            'Seçilen tarih aralığında log verisi bulunamadı.',
                            style: TextStyle(fontSize: 16),
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
