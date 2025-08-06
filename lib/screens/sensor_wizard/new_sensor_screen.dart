import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/sensor_wizard/sensor.dart';
import '../../models/sensor_wizard/protocol.dart';
import '../../services/restful_service.dart';
import '../../services/sensor_wizard/sensor_service.dart';
import 'channel_selection_screen.dart';

class NewSensorScreen extends StatefulWidget {
  final RESTfulService restfulService;

  const NewSensorScreen({
    super.key,
    required this.restfulService,
  });

  @override
  State<NewSensorScreen> createState() => _NewSensorScreenState();
}

class _NewSensorScreenState extends State<NewSensorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sensorService = SensorService();
  
  // Form controllers
  final _sensorNameController = TextEditingController();
  final _sensorDescriptionController = TextEditingController();
  final _minReferenceController = TextEditingController();
  final _maxReferenceController = TextEditingController();
  final _parameterNameController = TextEditingController();
  final _parameterUnitController = TextEditingController();
  
  // State variables
  String? _selectedSensorType; // 'analog' veya 'digital'
  Protocol? _selectedProtocol;
  List<Protocol> _protocols = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProtocols();
  }

  @override
  void dispose() {
    _sensorNameController.dispose();
    _sensorDescriptionController.dispose();
    _minReferenceController.dispose();
    _maxReferenceController.dispose();
    _parameterNameController.dispose();
    _parameterUnitController.dispose();
    super.dispose();
  }

  Future<void> _loadProtocols() async {
    try {
      final protocols = await _sensorService.loadProtocols();
      setState(() {
        _protocols = protocols;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Protokoller yüklenirken hata: $e'),
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
        title: const Text('Yeni Sensör Tanımla'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Text(
                'Yeni Sensör Tanımlama',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Sensör Adı
              TextFormField(
                controller: _sensorNameController,
                decoration: const InputDecoration(
                  labelText: 'Sensör Adı *',
                  hintText: 'Örn: Özel Sıcaklık Sensörü',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sensors),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sensör adı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sensör Açıklaması
              TextFormField(
                controller: _sensorDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Sensör Açıklaması',
                  hintText: 'Sensörün özelliklerini açıklayın',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Sensör Tipi Seçimi
              Text(
                'Sensör Tipi *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'Analog',
                      'Sürekli değer üreten sensörler',
                      Icons.analytics,
                      Colors.blue,
                      'analog',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      'Dijital',
                      'Açık/Kapalı durum sensörleri',
                      Icons.toggle_on,
                      Colors.green,
                      'digital',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Protokol Seçimi (Sadece Analog için)
              if (_selectedSensorType == 'analog') ...[
                Text(
                  'Protokol Seçimi *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProtocolDropdown(),
                const SizedBox(height: 24),
              ],

              // Referans Aralıkları
              Text(
                'Referans Aralıkları *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minReferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Değer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_down),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Minimum değer gereklidir';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxReferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Maksimum Değer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Maksimum değer gereklidir';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        final minValue = double.tryParse(_minReferenceController.text);
                        final maxValue = double.tryParse(value);
                        if (minValue != null && maxValue != null && maxValue <= minValue) {
                          return 'Maksimum değer minimum değerden büyük olmalıdır';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Parametre Bilgileri
              Text(
                'Parametre Bilgileri *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _parameterNameController,
                      decoration: const InputDecoration(
                        labelText: 'Parametre Adı',
                        hintText: 'Örn: Sıcaklık',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Parametre adı gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parameterUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Birim',
                        hintText: 'Örn: °C',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Birim gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Devam Et Butonu
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continueToChannelSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Devam Et',
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
    );
  }

  Widget _buildTypeCard(String title, String subtitle, IconData icon, Color color, String type) {
    final isSelected = _selectedSensorType == type;
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSensorType = type;
            if (type == 'digital') {
              _selectedProtocol = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? color.withOpacity(0.8) : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolDropdown() {
    return DropdownButtonFormField<Protocol>(
      value: _selectedProtocol,
      decoration: const InputDecoration(
        labelText: 'Protokol Seçin',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.settings),
      ),
      items: _protocols.map((protocol) {
        return DropdownMenuItem<Protocol>(
          value: protocol,
          child: Text('${protocol.name} (${protocol.description})'),
        );
      }).toList(),
      onChanged: (Protocol? value) {
        setState(() {
          _selectedProtocol = value;
        });
      },
      validator: (value) {
        if (_selectedSensorType == 'analog' && value == null) {
          return 'Protokol seçimi gereklidir';
        }
        return null;
      },
    );
  }

  void _continueToChannelSelection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSensorType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen sensör tipini seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSensorType == 'analog' && _selectedProtocol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen protokol seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Özel sensör oluştur
      final customSensor = Sensor(
        id: 999, // Geçici ID
        name: _sensorNameController.text.trim(),
        description: _sensorDescriptionController.text.trim(),
        type: _selectedSensorType!,
        protocol: _selectedProtocol?.name,
        parameters: [
          SensorParameter(
            id: 999, // Geçici ID
            name: _parameterNameController.text.trim(),
            unit: _parameterUnitController.text.trim(),
            minValue: double.parse(_minReferenceController.text),
            maxValue: double.parse(_maxReferenceController.text),
            offset: 0.0,
          ),
        ],
      );

      // Kanal seçim ekranına yönlendir
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChannelSelectionScreen(
              restfulService: widget.restfulService,
              selectedSensor: customSensor,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 