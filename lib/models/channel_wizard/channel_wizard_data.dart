class ChannelWizardData {
  // Step 1: Temel Bilgiler
  String channelName = '';
  String channelDescription = '';
  String channelColor = '#2196F3'; // Default mavi

  // Step 2: Sensör Seçimi
  String selectedSensor = 'TPEC 3 Parametreli Sensör';

  // Step 3: Ölçüm Seçimi
  List<String> selectedMeasurements = []; // WAT, WAP, EC

  // Step 4: Kategori Seçimi
  String selectedCategory = '';
  
  // Step 4.5: Sub Kategori Seçimi
  int? channelSubCategory;

  // Step 5: Birim Seçimi
  Map<String, String> selectedUnits = {}; // WAT -> °C, WAP -> bar, EC -> μS/cm

  // Step 6: Offset Değeri
  double offsetValue = 0.0;

  // Step 7: Alarm Ayarları
  Map<String, Map<String, double>> alarmSettings = {}; // measurement -> {min, max, minReset, maxReset}

  // Helper methods
  bool get isStep1Valid => channelName.isNotEmpty && channelDescription.isNotEmpty;
  
  bool get isStep2Valid => selectedSensor.isNotEmpty;
  
  bool get isStep3Valid => selectedMeasurements.isNotEmpty;
  
  bool get isStep4Valid => selectedCategory.isNotEmpty;
  
  bool get isStep4SubCategoryValid => channelSubCategory != null;
  
  bool get isStep5Valid => selectedUnits.length == selectedMeasurements.length;
  
  bool get isStep6Valid => true; // Offset her zaman geçerli
  
  bool get isStep7Valid => alarmSettings.isNotEmpty;

  // Reset method
  void reset() {
    channelName = '';
    channelDescription = '';
    channelColor = '#2196F3';
    selectedSensor = 'TPEC 3 Parametreli Sensör';
    selectedMeasurements.clear();
    selectedCategory = '';
    channelSubCategory = null;
    selectedUnits.clear();
    offsetValue = 0.0;
    alarmSettings.clear();
  }

  // Copy method
  ChannelWizardData copyWith({
    String? channelName,
    String? channelDescription,
    String? channelColor,
    String? selectedSensor,
    List<String>? selectedMeasurements,
    String? selectedCategory,
    int? channelSubCategory,
    Map<String, String>? selectedUnits,
    double? offsetValue,
    Map<String, Map<String, double>>? alarmSettings,
  }) {
    return ChannelWizardData()
      ..channelName = channelName ?? this.channelName
      ..channelDescription = channelDescription ?? this.channelDescription
      ..channelColor = channelColor ?? this.channelColor
      ..selectedSensor = selectedSensor ?? this.selectedSensor
      ..selectedMeasurements = selectedMeasurements ?? this.selectedMeasurements
      ..selectedCategory = selectedCategory ?? this.selectedCategory
      ..channelSubCategory = channelSubCategory ?? this.channelSubCategory
      ..selectedUnits = selectedUnits ?? this.selectedUnits
      ..offsetValue = offsetValue ?? this.offsetValue
      ..alarmSettings = alarmSettings ?? this.alarmSettings;
  }
}
