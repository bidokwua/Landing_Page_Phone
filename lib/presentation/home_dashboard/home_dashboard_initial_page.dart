import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_button_widget.dart';
import './widgets/alert_card_widget.dart';
import './widgets/maintenance_card_widget.dart';
import './widgets/robot_status_card_widget.dart';

class HomeDashboardInitialPage extends StatefulWidget {
  const HomeDashboardInitialPage({super.key});

  @override
  State<HomeDashboardInitialPage> createState() =>
      _HomeDashboardInitialPageState();
}

class _HomeDashboardInitialPageState extends State<HomeDashboardInitialPage> {
  final bool _isConnected = true;
  bool _isRefreshing = false;
  String _lastUpdated = "2026-02-08 07:15:23";

  final Map<String, dynamic> _robotStatus = {
    "battery": 87,
    "waterLevel": 65,
    "powderLevel": 42,
    "connectivity": "Strong",
    "status": "Idle",
    "location": "Home Base",
  };

  final List<Map<String, dynamic>> _alerts = [
    {
      "id": 1,
      "severity": "high",
      "title": "High Temperature Detected",
      "description": "Sensor reading 145°F in Zone A",
      "timestamp": "2026-02-08 06:45:12",
      "icon": "warning",
      "isExpanded": false,
    },
    {
      "id": 2,
      "severity": "medium",
      "title": "Low Water Level Warning",
      "description": "Water tank at 35% capacity",
      "timestamp": "2026-02-08 05:30:45",
      "icon": "water_drop",
      "isExpanded": false,
    },
    {
      "id": 3,
      "severity": "low",
      "title": "Patrol Completed",
      "description": "Perimeter patrol finished successfully",
      "timestamp": "2026-02-08 04:15:33",
      "icon": "check_circle",
      "isExpanded": false,
    },
    {
      "id": 4,
      "severity": "medium",
      "title": "Smoke Detected",
      "description": "Smoke index elevated in Zone B",
      "timestamp": "2026-02-08 03:22:18",
      "icon": "cloud",
      "isExpanded": false,
    },
    {
      "id": 5,
      "severity": "low",
      "title": "Battery Charging",
      "description": "Robot returned to base for charging",
      "timestamp": "2026-02-08 02:10:55",
      "icon": "battery_charging_full",
      "isExpanded": false,
    },
  ];

  final List<Map<String, dynamic>> _maintenanceTasks = [
    {
      "id": 1,
      "title": "Filter Cleaning",
      "dueDate": "2026-02-10",
      "priority": "high",
      "description": "Clean air intake filters",
      "isCompleted": false,
    },
    {
      "id": 2,
      "title": "Sensor Calibration",
      "dueDate": "2026-02-15",
      "priority": "medium",
      "description": "Calibrate temperature and smoke sensors",
      "isCompleted": false,
    },
    {
      "id": 3,
      "title": "Tank Inspection",
      "dueDate": "2026-02-20",
      "priority": "low",
      "description": "Inspect water and powder tanks for leaks",
      "isCompleted": false,
    },
  ];

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now().toString().substring(0, 19);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Telemetry data updated'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleStartPatrol() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Patrol'),
        content: Text('Begin perimeter patrol mission?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Patrol mission started')));
            },
            child: Text('Start'),
          ),
        ],
      ),
    );
  }

  void _handleReturnToBase() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return to Base'),
        content: Text('Command robot to return to home base?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Robot returning to base')),
              );
            },
            child: Text('Return'),
          ),
        ],
      ),
    );
  }

  void _handleEmergencyMode() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) {
        final pinController = TextEditingController();
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: const Color(0xFFE74C3C),
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text('Emergency Mode'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter PIN to activate Emergency Mode',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  hintText: 'Enter 4-digit PIN',
                  counterText: '',
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Mock PIN: 1234',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              onPressed: () {
                if (pinController.text == '1234') {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/emergency-mode-flow');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect PIN. Please use 1234'),
                      backgroundColor: const Color(0xFFE74C3C),
                    ),
                  );
                }
              },
              child: Text('Activate'),
            ),
          ],
        );
      },
    );
  }

  void _toggleAlertExpansion(int index) {
    setState(() {
      _alerts[index]["isExpanded"] = !(_alerts[index]["isExpanded"] as bool);
    });
  }

  void _completeMaintenanceTask(int index) {
    setState(() {
      _maintenanceTasks[index]["isCompleted"] = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task marked as completed')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: CustomAppBar(
                title: 'Firefly Defender',
                subtitle: 'Mission Control',
                variant: CustomAppBarVariant.withStatus,
                isConnected: _isConnected,
                actions: [
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'notifications',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Notifications')));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'wb_sunny',
                                  color: const Color(0xFFF39C12),
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '78°F Sunny',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              'Last updated: $_lastUpdated',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      RobotStatusCardWidget(
                        robotStatus: _robotStatus,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Robot status details')),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      ActionButtonWidget(
                        label: 'Start Patrol',
                        icon: 'play_arrow',
                        color: const Color(0xFF27AE60),
                        onPressed: _handleStartPatrol,
                      ),
                      SizedBox(height: 1.5.h),
                      ActionButtonWidget(
                        label: 'Return to Base',
                        icon: 'home',
                        color: const Color(0xFF3498DB),
                        onPressed: _handleReturnToBase,
                      ),
                      SizedBox(height: 1.5.h),
                      ActionButtonWidget(
                        label: 'Emergency Mode',
                        icon: 'warning',
                        color: const Color(0xFFE74C3C),
                        onPressed: _handleEmergencyMode,
                        requiresHold: true,
                      ),
                      SizedBox(height: 3.h),
                      Text('Recent Alerts', style: theme.textTheme.titleLarge),
                      SizedBox(height: 1.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _alerts.length > 5 ? 5 : _alerts.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.5.h),
                        itemBuilder: (context, index) {
                          return AlertCardWidget(
                            alert: _alerts[index],
                            onTap: () => _toggleAlertExpansion(index),
                          );
                        },
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Maintenance Reminders',
                        style: theme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 1.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _maintenanceTasks.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.5.h),
                        itemBuilder: (context, index) {
                          return MaintenanceCardWidget(
                            task: _maintenanceTasks[index],
                            onComplete: () => _completeMaintenanceTask(index),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
