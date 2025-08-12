import 'package:flutter/material.dart';
import '../../../models/channel_wizard/channel_wizard_data.dart';
import '../../../services/constant_data_service.dart';

class Step4SubCategorySelection extends StatefulWidget {
  final ChannelWizardData wizardData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4SubCategorySelection({
    super.key,
    required this.wizardData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step4SubCategorySelection> createState() => _Step4SubCategorySelectionState();
}

class _Step4SubCategorySelectionState extends State<Step4SubCategorySelection> {
  Map<int, String> _subCategories = {};
  int? _selectedSubCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Step4SubCategorySelection initState çağrıldı');
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    try {
      print('Sub kategoriler yükleniyor...');
      setState(() {
        _isLoading = true;
      });

      final subCategories = await ConstantDataService.getChannelSubCategories();
      print('Yüklenen sub kategoriler: $subCategories');
      print('Sub kategoriler sayısı: ${subCategories.length}');

      setState(() {
        _subCategories = subCategories;
        _isLoading = false;
      });
      print('State güncellendi, _subCategories: $_subCategories');
    } catch (e) {
      print('Sub kategoriler yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSubCategorySelected(int subCategoryId) {
    setState(() {
      _selectedSubCategoryId = subCategoryId;
    });
    // String değer olarak kaydet
    final subCategoryName = _subCategories[subCategoryId] ?? 'SolSahilSulama';
    widget.wizardData.selectedSubCategory = subCategoryName;
  }

  bool get _canProceed => _selectedSubCategoryId != null;

  @override
  Widget build(BuildContext context) {
    try {
      print('Build metodu çağrıldı');
      print('isLoading: $_isLoading');
      print('subCategories length: ${_subCategories.length}');
      print('selectedSubCategoryId: $_selectedSubCategoryId');
      
      return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Başlık
          Text(
            'Sub Kategori Seçimi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kanalınız için uygun sub kategoriyi seçin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Sub Kategori Listesi
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_subCategories.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sub kategori bulunamadı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
                        Container(
              height: 300, // Sabit yükseklik veriyoruz
              child: ListView.builder(
                itemCount: _subCategories.length,
                itemBuilder: (context, index) {
                  try {
                    if (_subCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final subCategoryId = _subCategories.keys.elementAt(index);
                    final subCategoryName = _subCategories[subCategoryId] ?? 'Unknown';
                    final isSelected = _selectedSubCategoryId == subCategoryId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 2,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        title: Text(
                          subCategoryName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'ID: $subCategoryId',
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              )
                            : null,
                        onTap: () => _onSubCategorySelected(subCategoryId),
                      ),
                    );
                  } catch (e) {
                    print('ListView.builder item build hatası: $e');
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),

          // Butonlar
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Geri',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceed ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      );
    } catch (e) {
      print('Build metodu genel hatası: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hata: $e',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
