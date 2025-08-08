import 'package:flutter/material.dart';
import '../services/restful_service.dart';
import 'dashboard_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with TickerProviderStateMixin {
  final _ipController = TextEditingController(text: '192.168.10.68');
  final _portController = TextEditingController(text: '8765');
  final _formKey = GlobalKey<FormState>();
  
  bool _isConnecting = false;
  bool _isScanning = false;
  List<String> _availableIPs = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    // Sayfa yüklendiğinde otomatik ağ taraması yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanNetwork();
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Ağdaki sunucuları tara
  Future<void> _scanNetwork() async {
    setState(() {
      _isScanning = true;
      _availableIPs.clear();
    });

    try {
      // Dinamik olarak mevcut IP'yi bul
      final currentIP = await _getLocalIP();
      final subnet = _getSubnet(currentIP);
      
      // Ağ taraması başlatılıyor
      
      // Farklı subnet'ler için test IP'leri - gerçek Android cihaz için optimize edildi
      final testIPs = [
        currentIP, // Mevcut IP
        ..._generateTestIPs(subnet), // Aynı subnet
        ..._generateTestIPs('192.168.1'), // Yaygın ev ağı
        ..._generateTestIPs('192.168.0'), // Yaygın ev ağı
        ..._generateTestIPs('10.0.0'), // Yaygın iş ağı
        ..._generateTestIPs('172.16.0'), // Yaygın iş ağı
        ..._generateTestIPs('172.20.0'), // Yaygın iş ağı
      ];
      
      for (final ip in testIPs) {
        try {
          final restfulService = RESTfulService(ip: ip, port: '8765');
          final isConnected = await restfulService.testConnection();
          
          if (isConnected) {
            setState(() {
              _availableIPs.add(ip);
            });
            // Sunucu bulundu
          }
        } catch (e) {
                      // IP kontrol hatası
        }
      }
      
      // Eğer sunucu bulunduysa ilkini seç
      if (_availableIPs.isNotEmpty) {
        setState(() {
          _ipController.text = _availableIPs.first;
        });
      }
      
    } catch (e) {
      // Ağ tarama hatası
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Yerel IP adresini al
  Future<String> _getLocalIP() async {
    try {
      // Gerçek Android cihazda IP algılama için daha gelişmiş yöntem
      // Şimdilik sabit IP'ler kullanıyoruz, gerçek uygulamada network_info_plus paketi kullanılabilir
      return '172.20.10.3'; // Mevcut IP
    } catch (e) {
      // IP alma hatası
      return '192.168.1.100'; // Fallback
    }
  }

  /// IP'den subnet'i çıkar
  String _getSubnet(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return '192.168.1';
  }

  /// Test IP'leri oluştur - gerçek Android cihaz için optimize edildi
  List<String> _generateTestIPs(String subnet) {
    return [
      '$subnet.1',    // Router
      '$subnet.2',    // Yaygın DHCP aralığı
      '$subnet.10',   // Yaygın DHCP aralığı
      '$subnet.50',   // Yaygın DHCP aralığı
      '$subnet.100',  // Yaygın DHCP aralığı
      '$subnet.200',  // Yaygın DHCP aralığı
      '$subnet.254',  // Son IP
    ];
  }

  Future<void> _connectToServer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final ip = _ipController.text.trim();
      final port = _portController.text.trim();
      
      // Bağlantı deneniyor
      
      // IP ve port'u RESTfulService'e geçir
      final restfulService = RESTfulService(ip: ip, port: port);
      
      // RESTful API bağlantısını test et
      final isConnected = await restfulService.testConnection();
      
      if (isConnected) {
        // Bağlantı başarılı
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(restfulService: restfulService),
            ),
          );
        }
      } else {
        throw Exception('Sunucuya bağlanılamadı. IP: $ip, Port: $port');
      }
    } catch (e) {
              // Bağlantı hatası
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı hatası: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo ve Başlık
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 64,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'HIDROLINK',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sensör Ölçüm Sistemi',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // IP Field with Scan Button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ipController,
                              decoration: InputDecoration(
                                labelText: 'IP Adresi',
                                hintText: '192.168.1.100',
                                prefixIcon: const Icon(Icons.computer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'IP adresi gerekli';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isScanning ? null : _scanNetwork,
                              icon: _isScanning 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                              label: Text(_isScanning ? 'Taranıyor...' : 'Tara'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Bulunan IP'leri göster
                      if (_availableIPs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bulunan Sunucular:',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _availableIPs.map((ip) => 
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _ipController.text = ip;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _ipController.text == ip 
                                          ? Theme.of(context).colorScheme.primary 
                                          : Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      child: Text(
                                        ip,
                                        style: TextStyle(
                                          color: _ipController.text == ip 
                                            ? Theme.of(context).colorScheme.onPrimary 
                                            : Theme.of(context).colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Port Field
                      TextFormField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: 'Port',
                          hintText: '8765',
                          prefixIcon: const Icon(Icons.settings_ethernet),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Port gerekli';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return 'Geçerli port numarası girin (1-65535)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Connect Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isConnecting ? null : _connectToServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isConnecting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Bağlanıyor...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wifi),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Bağlan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 