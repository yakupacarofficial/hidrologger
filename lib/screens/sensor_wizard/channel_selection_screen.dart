import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/sensor_wizard/sensor.dart';
import '../../models/channel_data.dart';
import '../../services/restful_service.dart';
import '../../services/constant_data_service.dart';

class ChannelSelectionScreen extends StatefulWidget {
  final RESTfulService restfulService;
  final Sensor selectedSensor;

  const ChannelSelectionScreen({
    super.key,
    required this.restfulService,
    required this.selectedSensor,
  });

  @override
  State<ChannelSelectionScreen> createState() => _ChannelSelectionScreenState();
}

class _ChannelSelectionScreenState extends State<ChannelSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _offsetController = TextEditingController(text: '0.0');
  final _minAlarmController = TextEditingController();
  final _maxAlarmController = TextEditingController();
  final _alarmInfoController = TextEditingController();
  final _dataPostFrequencyController = TextEditingController(text: '1000');
  
  // State variables
  List<Map<String, dynamic>> _channelParameters = [];
  List<Map<String, dynamic>> _filteredParameters = [];
  Map<String, dynamic>? _selectedParameter;
  int _nextChannelId = 1;
  bool _isLoading = false;
  bool _isSaving = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Color picker for alarm
  String _selectedColor = '#FF0000';
  final List<String> _availableColors = [
    '#FF0000', // Kırmızı
    '#00FF00', // Yeşil
    '#0000FF', // Mavi
    '#FFFF00', // Sarı
    '#FF00FF', // Magenta
    '#00FFFF', // Cyan
    '#FFA500', // Turuncu
    '#800080', // Mor
    '#008000', // Koyu Yeşil
    '#FFC0CB', // Pembe
  ];
  
  // Kategori ve value type seçimi için
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _valueTypes = [];
  Map<String, dynamic>? _selectedCategory;
  Map<String, dynamic>? _selectedSubCategory;
  Map<String, dynamic>? _selectedValueType;

  @override
  void initState() {
    super.initState();
    _loadChannelParameters();
    _loadCategoriesAndValueTypes();
    _calculateNextChannelId();
  }

  @override
  void dispose() {
    _offsetController.dispose();
    _minAlarmController.dispose();
    _maxAlarmController.dispose();
    _alarmInfoController.dispose();
    _dataPostFrequencyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChannelParameters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final parameters = await ConstantDataService.loadChannelParameters();
      setState(() {
        _channelParameters = parameters;
        _filteredParameters = parameters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kanal parametreleri yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCategoriesAndValueTypes() async {
    try {
      // Kategorileri yükle
      final categories = await ConstantDataService.loadSpecificConstantData('channel_category.json');
      if (categories != null && categories['channel_category'] != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(categories['channel_category']);
        });
      }
      
      // Alt kategorileri yükle
      final subCategories = await ConstantDataService.loadSpecificConstantData('channel_sub_category.json');
      if (subCategories != null && subCategories['channel_sub_category'] != null) {
        setState(() {
          _subCategories = List<Map<String, dynamic>>.from(subCategories['channel_sub_category']);
        });
      }
      
      // Value type'ları yükle
      final valueTypes = await ConstantDataService.loadSpecificConstantData('value_type.json');
      if (valueTypes != null && valueTypes['value_type'] != null) {
        setState(() {
          _valueTypes = List<Map<String, dynamic>>.from(valueTypes['value_type']);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori ve value type verileri yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _calculateNextChannelId() async {
    try {
      final currentData = await widget.restfulService.fetchAllData();
      if (currentData != null && currentData.channels.isNotEmpty) {
        final maxId = currentData.channels.map((c) => c.id).reduce((a, b) => a > b ? a : b);
        setState(() {
          _nextChannelId = maxId + 1;
        });
      }
    } catch (e) {
      // Hata durumunda 1'den başla
      setState(() {
        _nextChannelId = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Kanal Seçimi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sensör Bilgileri
                    _buildSensorInfoCard(),
                    const SizedBox(height: 24),

                    // Kanal ID
                    _buildChannelIdCard(),
                    const SizedBox(height: 24),

                    // Parametre Seçimi
                    _buildParameterSelection(),
                    const SizedBox(height: 24),

                    // Kategori Seçimi
                    _buildCategorySelection(),
                    const SizedBox(height: 24),

                    // Offset Değeri
                    _buildOffsetField(),
                    const SizedBox(height: 24),

                    // Alarm Ayarları
                    _buildAlarmSettings(),
                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSensorInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seçilen Sensör',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Sensör Adı', widget.selectedSensor.name),
            _buildInfoRow('Tip', widget.selectedSensor.type.toUpperCase()),
            if (widget.selectedSensor.protocol != null)
              _buildInfoRow('Protokol', widget.selectedSensor.protocol!),
            _buildInfoRow('Parametre Sayısı', '${widget.selectedSensor.parameters.length}'),
            if (widget.selectedSensor.description.isNotEmpty)
              _buildInfoRow('Açıklama', widget.selectedSensor.description),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelIdCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kanal Bilgileri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Kanal ID', '$_nextChannelId'),
            _buildInfoRow('Durum', 'Yeni Kanal'),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterSelection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kanal Parametresi Seçimi *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kanalın hangi parametreyi ölçeceğini seçin:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Parametre arama kutusu
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Parametre Ara',
                hintText: 'Parametre adı veya açıklaması yazın...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterParameters('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterParameters,
            ),
            const SizedBox(height: 12),
            
                         // Parametre listesi
             Container(
               height: 200,
               decoration: BoxDecoration(
                 border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: _filteredParameters.isEmpty
                   ? Center(
                       child: Text(
                         'Arama kriterlerine uygun parametre bulunamadı',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                         ),
                       ),
                     )
                   : ListView.builder(
                       itemCount: _filteredParameters.length,
                       itemBuilder: (context, index) {
                         final param = _filteredParameters[index];
                  final isSelected = _selectedParameter?['id'] == param['id'];
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getParameterIcon(param['name']),
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      param['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      param['description'] ?? 'Açıklama yok',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected 
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedParameter = param;
                      });
                    },
                  );
                },
              ),
            ),
            
            if (_selectedParameter != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seçilen: ${_selectedParameter!['name']} - ${_selectedParameter!['description'] ?? 'Açıklama yok'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori ve Value Type Seçimi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Ana Kategori
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Ana Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: category,
                  child: Text(category['name'] ?? 'Bilinmeyen'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSubCategory = null; // Alt kategoriyi sıfırla
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen ana kategori seçin';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Alt Kategori
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedSubCategory,
              decoration: const InputDecoration(
                labelText: 'Alt Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
              items: _subCategories.map((subCategory) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: subCategory,
                  child: Text(subCategory['name'] ?? 'Bilinmeyen'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen alt kategori seçin';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Value Type
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedValueType,
              decoration: const InputDecoration(
                labelText: 'Value Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.data_usage),
              ),
              items: _valueTypes.map((valueType) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: valueType,
                  child: Text(valueType['name'] ?? 'Bilinmeyen'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValueType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen value type seçin';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffsetField() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offset Değeri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sensör değerine eklenecek offset değeri:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _offsetController,
              decoration: const InputDecoration(
                labelText: 'Offset Değeri',
                hintText: '0.0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Offset değeri gereklidir';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm Ayarları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kanal için alarm değerlerini belirleyin:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Minimum Alarm
            TextFormField(
              controller: _minAlarmController,
              decoration: const InputDecoration(
                labelText: 'Minimum Alarm Değeri',
                hintText: 'Örn: 10.0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_down),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
            ),
            const SizedBox(height: 12),
            
            // Maksimum Alarm
            TextFormField(
              controller: _maxAlarmController,
              decoration: const InputDecoration(
                labelText: 'Maksimum Alarm Değeri',
                hintText: 'Örn: 50.0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
            ),
            const SizedBox(height: 12),
            
            // Alarm Bilgisi
            TextFormField(
              controller: _alarmInfoController,
              decoration: const InputDecoration(
                labelText: 'Alarm Bilgisi',
                hintText: 'Örn: Sıcaklık çok yüksek',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            
            // Data Post Frequency
            TextFormField(
              controller: _dataPostFrequencyController,
              decoration: const InputDecoration(
                labelText: 'Veri Gönderme Sıklığı (ms)',
                hintText: '1000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))],
            ),
            const SizedBox(height: 16),
            
            // Color Picker
            Text(
              'Renk Seçin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChannel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Kanalı Kaydet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterParameters(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredParameters = _channelParameters;
      } else {
        _filteredParameters = _channelParameters.where((param) {
          final name = param['name']?.toString().toLowerCase() ?? '';
          final description = param['description']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    });
  }

  IconData _getParameterIcon(String parameterName) {
    switch (parameterName.toUpperCase()) {
      case 'AT':
      case 'AH':
        return Icons.thermostat;
      case 'AP':
        return Icons.speed;
      case 'EC':
      case 'PH':
        return Icons.science;
      case 'PR':
        return Icons.water_drop;
      case 'WAL':
      case 'WAF':
      case 'WAA':
      case 'WAS':
        return Icons.water;
      case 'SM':
        return Icons.grass;
      case 'GR':
      case 'DR':
      case 'SD':
        return Icons.wb_sunny;
      case 'LW':
        return Icons.eco;
      case 'ETo':
      case 'EVO':
        return Icons.opacity;
      case 'SWD':
        return Icons.ac_unit;
      default:
        return Icons.sensors;
    }
  }

  Future<void> _saveChannel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedParameter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kanal parametresini seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('Kanal kaydetme başlatılıyor...');
      print('Seçilen parametre: $_selectedParameter');
      print('Next Channel ID: $_nextChannelId');
      
      // Yeni kanal verisi oluştur
      final newChannel = {
        'id': _nextChannelId,
        'name': widget.selectedSensor.name,
        'description': widget.selectedSensor.description,
        'channel_category': _selectedCategory?['id'] ?? _selectedParameter!['category_id'] ?? 1,
        'channel_sub_category': _selectedSubCategory?['id'] ?? _selectedParameter!['sub_category_id'] ?? 1,
        'channel_parameter': _selectedParameter!['id'],
        'measurement_unit': _selectedParameter!['unit_id'] ?? 1,
        'value_type': _selectedValueType?['id'] ?? 1,
        'log_interval': 1000, // Varsayılan değer
        'offset': double.parse(_offsetController.text),
      };

      print('Oluşturulan kanal verisi: $newChannel');

      // Kanalı sunucuya kaydet
      final success = await widget.restfulService.createChannel(newChannel);
      
      if (success) {
        // Alarm ayarları varsa kaydet
        if (_minAlarmController.text.isNotEmpty || _maxAlarmController.text.isNotEmpty) {
          // Alarm verilerini oluştur
          final minValue = _minAlarmController.text.isNotEmpty 
              ? double.parse(_minAlarmController.text) 
              : 0.0;
          final maxValue = _maxAlarmController.text.isNotEmpty 
              ? double.parse(_maxAlarmController.text) 
              : 100.0;
          final alarmInfo = _alarmInfoController.text.isNotEmpty 
              ? _alarmInfoController.text 
              : 'Kanal $_nextChannelId alarmı';
          
          // Alarm nesnesi oluştur
          final dataPostFrequency = int.tryParse(_dataPostFrequencyController.text) ?? 1000;
          final alarm = Alarm(
            minValue: minValue,
            maxValue: maxValue,
            color: _selectedColor,
            dataPostFrequency: dataPostFrequency,
          );
          
          // AlarmParameter oluştur
          final alarmParameter = AlarmParameter(
            channelId: _nextChannelId,
            alarmInfo: alarmInfo,
            alarms: [alarm],
          );
          
          // Alarm verilerini JSON formatına çevir
          final parameterKey = 'parameter$_nextChannelId';
          final alarmData = {
            parameterKey: alarmParameter.toJson(),
          };

          await widget.restfulService.saveAlarmData(alarmData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kanal $_nextChannelId başarıyla kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Dashboard'a geri dön
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        print('Kanal kaydetme başarısız - sunucu yanıtı');
        throw Exception('Kanal kaydedilemedi - sunucu hatası');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kanal kaydedilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
} 