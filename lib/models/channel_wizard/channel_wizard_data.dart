class ChannelWizardData {
  // Step 1: Temel Bilgiler
  String channelName = '';
  String channelDescription = '';
  String channelColor = '#2196F3'; // Default mavi

  // Step 2: Sensör Seçimi
  String selectedSensor = 'DS18B20';

  // Step 3: Ölçüm Seçimi
  String selectedParameter = 'temperature';

  // Step 4: Kategori Seçimi
  String selectedCategory = 'Kuyu';
  
  // Step 4.5: Sub Kategori Seçimi
  String selectedSubCategory = 'SolSahilSulama';

  // Step 5: Birim Seçimi
  String selectedUnit = '°C';

  // Step 6: Offset Değeri
  double offsetValue = 0.0;

  // Step 7: Alarm Ayarları
  double minValue = -10.0;
  double maxValue = 50.0;
  double minValueReset = 0.0;
  double maxValueReset = 40.0;

  // Helper methods
  bool get isStep1Valid => channelName.isNotEmpty && channelDescription.isNotEmpty;
  
  bool get isStep2Valid => selectedSensor.isNotEmpty;
  
  bool get isStep3Valid => selectedParameter.isNotEmpty;
  
  bool get isStep4Valid => selectedCategory.isNotEmpty;
  
  bool get isStep4SubCategoryValid => selectedSubCategory.isNotEmpty;
  
  bool get isStep5Valid => selectedUnit.isNotEmpty;
  
  bool get isStep6Valid => true; // Offset her zaman geçerli
  
  bool get isStep7Valid => minValue < maxValue;

  // Reset method
  void reset() {
    channelName = '';
    channelDescription = '';
    channelColor = '#2196F3';
    selectedSensor = 'DS18B20';
    selectedParameter = 'temperature';
    selectedCategory = 'Kuyu';
    selectedSubCategory = 'SolSahilSulama';
    selectedUnit = '°C';
    offsetValue = 0.0;
    minValue = -10.0;
    maxValue = 50.0;
    minValueReset = 0.0;
    maxValueReset = 40.0;
  }

  // Copy method
  ChannelWizardData copyWith({
    String? channelName,
    String? channelDescription,
    String? channelColor,
    String? selectedSensor,
    String? selectedParameter,
    String? selectedCategory,
    String? selectedSubCategory,
    String? selectedUnit,
    double? offsetValue,
    double? minValue,
    double? maxValue,
    double? minValueReset,
    double? maxValueReset,
  }) {
    return ChannelWizardData()
      ..channelName = channelName ?? this.channelName
      ..channelDescription = channelDescription ?? this.channelDescription
      ..channelColor = channelColor ?? this.channelColor
      ..selectedSensor = selectedSensor ?? this.selectedSensor
      ..selectedParameter = selectedParameter ?? this.selectedParameter
      ..selectedCategory = selectedCategory ?? this.selectedCategory
      ..selectedSubCategory = selectedSubCategory ?? this.selectedSubCategory
      ..selectedUnit = selectedUnit ?? this.selectedUnit
      ..offsetValue = offsetValue ?? this.offsetValue
      ..minValue = minValue ?? this.minValue
      ..maxValue = maxValue ?? this.maxValue
      ..minValueReset = minValueReset ?? this.minValueReset
      ..maxValueReset = maxValueReset ?? this.maxValueReset;
  }
}
