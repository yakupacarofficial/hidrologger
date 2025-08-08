import 'package:flutter/material.dart';
import '../../services/restful_service.dart';
import 'steps/step1_basic_info.dart';
import 'steps/step2_sensor_selection.dart';
import 'steps/step3_measurement_selection.dart';
import 'steps/step4_category_selection.dart';
import 'steps/step5_unit_selection.dart';
import 'steps/step6_offset_input.dart';
import 'steps/step7_alarm_settings.dart';
import 'steps/step8_summary.dart';
import '../../models/channel_wizard/channel_wizard_data.dart';

class ChannelWizardScreen extends StatefulWidget {
  final RESTfulService restfulService;

  const ChannelWizardScreen({
    super.key,
    required this.restfulService,
  });

  @override
  State<ChannelWizardScreen> createState() => _ChannelWizardScreenState();
}

class _ChannelWizardScreenState extends State<ChannelWizardScreen> {
  int _currentStep = 0;
  final ChannelWizardData _wizardData = ChannelWizardData();

  final List<Widget> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps.clear();
    _steps.addAll([
      Step1BasicInfo(
        wizardData: _wizardData,
        onNext: _nextStep,
      ),
      Step2SensorSelection(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step3MeasurementSelection(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step4CategorySelection(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step5UnitSelection(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step6OffsetInput(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step7AlarmSettings(
        wizardData: _wizardData,
        onNext: _nextStep,
        onBack: _previousStep,
      ),
      Step8Summary(
        wizardData: _wizardData,
        restfulService: widget.restfulService,
        onBack: _previousStep,
      ),
    ]);
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanal Ekleme Sihirbazı'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adım ${_currentStep + 1} / ${_steps.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Step Content
          Expanded(
            child: _steps[_currentStep],
          ),
        ],
      ),
    );
  }
}
