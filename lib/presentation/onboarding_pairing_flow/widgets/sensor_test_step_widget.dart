import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SensorTestStepWidget extends StatefulWidget {
  final VoidCallback onTestComplete;

  const SensorTestStepWidget({super.key, required this.onTestComplete});

  @override
  State<SensorTestStepWidget> createState() => _SensorTestStepWidgetState();
}

class _SensorTestStepWidgetState extends State<SensorTestStepWidget> {
  bool _isTesting = false;
  final Map<String, bool?> _sensorStatus = {
    'camera': null,
    'gps': null,
    'temperature': null,
    'smoke': null,
  };

  @override
  void initState() {
    super.initState();
    _startSensorTest();
  }

  Future<void> _startSensorTest() async {
    setState(() {
      _isTesting = true;
    });

    await _testSensor('camera', 2);
    await _testSensor('gps', 2);
    await _testSensor('temperature', 2);
    await _testSensor('smoke', 2);

    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testSensor(String sensor, int delaySeconds) async {
    await Future.delayed(Duration(seconds: delaySeconds));
    setState(() {
      _sensorStatus[sensor] = true;
    });
  }

  bool get _allSensorsPassed {
    return _sensorStatus.values.every((status) => status == true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sensor Connectivity Test',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Testing robot sensors and connectivity',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildSensorCard(
                    theme,
                    sensor: 'camera',
                    title: 'Camera System',
                    description: 'Visual monitoring and inspection',
                    iconName: 'videocam',
                  ),
                  SizedBox(height: 2.h),
                  _buildSensorCard(
                    theme,
                    sensor: 'gps',
                    title: 'GPS Module',
                    description: 'Location tracking and navigation',
                    iconName: 'location_on',
                  ),
                  SizedBox(height: 2.h),
                  _buildSensorCard(
                    theme,
                    sensor: 'temperature',
                    title: 'Temperature Sensor',
                    description: 'Heat detection and monitoring',
                    iconName: 'thermostat',
                  ),
                  SizedBox(height: 2.h),
                  _buildSensorCard(
                    theme,
                    sensor: 'smoke',
                    title: 'Smoke Detector',
                    description: 'Smoke and air quality monitoring',
                    iconName: 'sensors',
                  ),
                  SizedBox(height: 3.h),
                  _buildTestSummary(theme),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _allSensorsPassed && !_isTesting
                  ? widget.onTestComplete
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.surface,
                disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isTesting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Testing Sensors...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Complete Setup',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    ThemeData theme, {
    required String sensor,
    required String title,
    required String description,
    required String iconName,
  }) {
    final bool? status = _sensorStatus[sensor];
    final Color statusColor = status == null
        ? theme.colorScheme.onSurfaceVariant
        : status
        ? Color(0xFF27AE60)
        : Color(0xFFE74C3C);
    final String statusText = status == null
        ? 'Testing...'
        : status
        ? 'Connected'
        : 'Failed';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == true
              ? Color(0xFF27AE60).withValues(alpha: 0.3)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: status == null
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: status ? 'check_circle' : 'error',
                      color: statusColor,
                      size: 32,
                    ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSummary(ThemeData theme) {
    final int totalSensors = _sensorStatus.length;
    final int passedSensors = _sensorStatus.values
        .where((status) => status == true)
        .length;
    final int failedSensors = _sensorStatus.values
        .where((status) => status == false)
        .length;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _allSensorsPassed
            ? Color(0xFF27AE60).withValues(alpha: 0.1)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _allSensorsPassed
              ? Color(0xFF27AE60).withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: _allSensorsPassed ? 'check_circle' : 'info',
                color: _allSensorsPassed
                    ? Color(0xFF27AE60)
                    : theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                _allSensorsPassed ? 'All Systems Ready' : 'Testing in Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _allSensorsPassed
                      ? Color(0xFF27AE60)
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildStatusBadge(
                theme,
                '$passedSensors/$totalSensors',
                'Passed',
                Color(0xFF27AE60),
              ),
              SizedBox(width: 2.w),
              if (failedSensors > 0)
                _buildStatusBadge(
                  theme,
                  '$failedSensors',
                  'Failed',
                  Color(0xFFE74C3C),
                ),
            ],
          ),
          if (_allSensorsPassed) ...[
            SizedBox(height: 1.h),
            Text(
              'Your Firefly robot is ready to protect your property!',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    ThemeData theme,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
