import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/emergency_contacts_widget.dart';
import './widgets/manual_controls_widget.dart';
import './widgets/status_display_widget.dart';
import './widgets/suppression_controls_widget.dart';
import './widgets/timeline_widget.dart';

/// Emergency Mode Flow Screen
/// Provides guided wildfire response with constrained controls ensuring safety during high-stress situations.
/// Activated via PIN-protected dashboard button with full-screen modal presentation.
class EmergencyModeFlow extends StatefulWidget {
  const EmergencyModeFlow({super.key});

  @override
  State<EmergencyModeFlow> createState() => _EmergencyModeFlowState();
}

class _EmergencyModeFlowState extends State<EmergencyModeFlow>
    with TickerProviderStateMixin {
  // Robot status states
  String _currentStatus = 'Verifying';
  bool _isDefending = false;
  final bool _isReturning = false;
  final bool _isOffline = false;

  // Timeline tracking
  final List<Map<String, dynamic>> _timelineSteps = [
    {
      "id": 1,
      "title": "Initial Verification",
      "description": "Scanning property perimeter for threats",
      "completed": true,
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
    },
    {
      "id": 2,
      "title": "Threat Assessment",
      "description": "Analyzing heat signatures and smoke levels",
      "completed": true,
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      "id": 3,
      "title": "Defense Position",
      "description": "Moving to optimal defense location",
      "completed": false,
      "estimatedTime": "2 min",
    },
    {
      "id": 4,
      "title": "Active Defense",
      "description": "Monitoring and suppressing threats",
      "completed": false,
      "estimatedTime": "15 min",
    },
    {
      "id": 5,
      "title": "Return to Base",
      "description": "Safe return after threat neutralization",
      "completed": false,
      "estimatedTime": "5 min",
    },
  ];

  // Control states
  bool _manualControlsExpanded = false;
  bool _suppressionControlsExpanded = false;
  String? _activeDirection;
  bool _waterSystemArmed = false;
  bool _powderSystemArmed = false;

  // Emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      "id": 1,
      "name": "Fire Department",
      "phone": "911",
      "type": "emergency",
      "notified": true,
      "timestamp": DateTime.now().subtract(Duration(minutes: 4)),
    },
    {
      "id": 2,
      "name": "Sarah Johnson",
      "phone": "+1 (555) 123-4567",
      "type": "family",
      "notified": true,
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      "id": 3,
      "name": "Neighbor Watch",
      "phone": "+1 (555) 987-6543",
      "type": "neighbor",
      "notified": false,
    },
  ];

  // Robot telemetry
  final Map<String, dynamic> _robotTelemetry = {
    "battery": 78,
    "waterLevel": 65,
    "powderLevel": 82,
    "temperature": 42,
    "smokeIndex": 3.2,
    "gpsLat": 37.7749,
    "gpsLon": -122.4194,
    "heading": 245,
    "speed": 0.5,
  };

  // Auto-notifications
  final List<Map<String, dynamic>> _autoNotifications = [
    {
      "id": 1,
      "message": "Emergency Mode activated - Fire Department notified",
      "status": "delivered",
      "timestamp": DateTime.now().subtract(Duration(minutes: 4)),
    },
    {
      "id": 2,
      "message": "Family contacts alerted with location sharing",
      "status": "delivered",
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      "id": 3,
      "message": "Insurance documentation started",
      "status": "pending",
      "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
    },
  ];

  late AnimationController _statusAnimationController;
  late Animation<double> _statusPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preventSleep();
    _setMaxBrightness();
    _startEmergencyMode();
  }

  void _initializeAnimations() {
    _statusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _statusPulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _statusAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _preventSleep() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setMaxBrightness() {
    // Maximum brightness for emergency visibility
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _startEmergencyMode() {
    // Simulate emergency mode progression
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _currentStatus = 'Defending';
          _isDefending = true;
          _timelineSteps[2]['completed'] = true;
          _timelineSteps[2]['timestamp'] = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _statusAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await _showExitConfirmation();
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Emergency Mode?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Exiting Emergency Mode will stop active defense operations. Enter PIN to confirm.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _showPinVerification(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Enter PIN'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showPinVerification() {
    // Mock PIN verification - in production, use actual PIN verification
    Navigator.of(context).pop(true);
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _handleManualControl(String direction) {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeDirection = direction;
    });

    // Auto-timeout after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _activeDirection == direction) {
        setState(() {
          _activeDirection = null;
        });
      }
    });
  }

  void _handleSuppressionArm(String system) {
    HapticFeedback.heavyImpact();
    setState(() {
      if (system == 'water') {
        _waterSystemArmed = !_waterSystemArmed;
        if (_waterSystemArmed) _powderSystemArmed = false;
      } else {
        _powderSystemArmed = !_powderSystemArmed;
        if (_powderSystemArmed) _waterSystemArmed = false;
      }
    });
  }

  void _handleSuppressionActivate(String system) {
    if ((system == 'water' && !_waterSystemArmed) ||
        (system == 'powder' && !_powderSystemArmed)) {
      return;
    }

    _showSuppressionConfirmation(system);
  }

  void _showSuppressionConfirmation(String system) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.error,
        title: Text(
          'Activate ${system == 'water' ? 'Water' : 'Powder'} Suppression?',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'This will activate the suppression system. Hold CONFIRM for 3 seconds to proceed.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _activateSuppression(system);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  void _activateSuppression(String system) {
    HapticFeedback.heavyImpact();
    setState(() {
      if (system == 'water') {
        _waterSystemArmed = false;
      } else {
        _powderSystemArmed = false;
      }
    });

    // Show activation countdown
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${system == 'water' ? 'Water' : 'Powder'} suppression activated',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _callEmergencyContact(Map<String, dynamic> contact) {
    HapticFeedback.lightImpact();
    // In production, use url_launcher to make actual phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${contact['name']}...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.error,
        appBar: CustomAppBar(
          title: 'EMERGENCY MODE',
          variant: CustomAppBarVariant.emergency,
          isEmergencyMode: true,
          onBackPressed: () => _showExitConfirmation(),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Column(
              children: [
                // Status Display - Top Half
                Expanded(
                  flex: 4,
                  child: StatusDisplayWidget(
                    currentStatus: _currentStatus,
                    isDefending: _isDefending,
                    isReturning: _isReturning,
                    isOffline: _isOffline,
                    robotTelemetry: _robotTelemetry,
                    statusPulseAnimation: _statusPulseAnimation,
                  ),
                ),
                SizedBox(height: 2.h),

                // Timeline and Controls - Bottom Half
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Timeline
                        TimelineWidget(timelineSteps: _timelineSteps),
                        SizedBox(height: 2.h),

                        // Manual Controls
                        ManualControlsWidget(
                          isExpanded: _manualControlsExpanded,
                          activeDirection: _activeDirection,
                          onToggleExpanded: () {
                            setState(() {
                              _manualControlsExpanded =
                                  !_manualControlsExpanded;
                              if (_manualControlsExpanded) {
                                _suppressionControlsExpanded = false;
                              }
                            });
                          },
                          onDirectionControl: _handleManualControl,
                        ),
                        SizedBox(height: 2.h),

                        // Suppression Controls
                        SuppressionControlsWidget(
                          isExpanded: _suppressionControlsExpanded,
                          waterSystemArmed: _waterSystemArmed,
                          powderSystemArmed: _powderSystemArmed,
                          waterLevel: _robotTelemetry['waterLevel'],
                          powderLevel: _robotTelemetry['powderLevel'],
                          onToggleExpanded: () {
                            setState(() {
                              _suppressionControlsExpanded =
                                  !_suppressionControlsExpanded;
                              if (_suppressionControlsExpanded) {
                                _manualControlsExpanded = false;
                              }
                            });
                          },
                          onArmSystem: _handleSuppressionArm,
                          onActivateSystem: _handleSuppressionActivate,
                        ),
                        SizedBox(height: 2.h),

                        // Emergency Contacts
                        EmergencyContactsWidget(
                          emergencyContacts: _emergencyContacts,
                          autoNotifications: _autoNotifications,
                          onCallContact: _callEmergencyContact,
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
    );
  }
}
