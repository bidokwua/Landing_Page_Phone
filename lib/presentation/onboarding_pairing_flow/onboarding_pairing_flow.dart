import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/account_creation_step_widget.dart';
import './widgets/calibration_step_widget.dart';
import './widgets/connection_method_step_widget.dart';
import './widgets/qr_scanner_step_widget.dart';
import './widgets/sensor_test_step_widget.dart';
import './widgets/welcome_step_widget.dart';

class OnboardingPairingFlow extends StatefulWidget {
  const OnboardingPairingFlow({super.key});

  @override
  State<OnboardingPairingFlow> createState() => _OnboardingPairingFlowState();
}

class _OnboardingPairingFlowState extends State<OnboardingPairingFlow> {
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Form data storage
  String _email = '';
  String _password = '';
  String _robotId = '';
  String _connectionMethod = '';
  Map<String, dynamic> _calibrationData = {};
  bool _safetyDisclaimerAccepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(theme),
            Expanded(child: _buildCurrentStep(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_currentStep > 0)
                TextButton(onPressed: _goToPreviousStep, child: Text('Back')),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: theme.colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 0.6.h,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    return _currentStep == 0
        ? WelcomeStepWidget(
            onAccept: (accepted) {
              setState(() {
                _safetyDisclaimerAccepted = accepted;
              });
            },
            onNext: _safetyDisclaimerAccepted ? _goToNextStep : null,
          )
        : _currentStep == 1
        ? AccountCreationStepWidget(
            onEmailChanged: (email) {
              setState(() {
                _email = email;
              });
            },
            onPasswordChanged: (password) {
              setState(() {
                _password = password;
              });
            },
            onNext: _email.isNotEmpty && _password.length >= 8
                ? _goToNextStep
                : null,
          )
        : _currentStep == 2
        ? QrScannerStepWidget(
            onScanned: (robotId) {
              setState(() {
                _robotId = robotId;
              });
              _goToNextStep();
            },
          )
        : _currentStep == 3
        ? ConnectionMethodStepWidget(
            onMethodSelected: (method) {
              setState(() {
                _connectionMethod = method;
              });
              _goToNextStep();
            },
          )
        : _currentStep == 4
        ? CalibrationStepWidget(
            onCalibrationComplete: (data) {
              setState(() {
                _calibrationData = data;
              });
              _goToNextStep();
            },
          )
        : SensorTestStepWidget(onTestComplete: _completeOnboarding);
  }

  void _goToNextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeOnboarding() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/home-dashboard');
  }
}
