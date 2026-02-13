import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RobotLocationMarkerWidget extends StatelessWidget {
  final double batteryLevel;
  final String status;
  final bool isConnected;

  const RobotLocationMarkerWidget({
    super.key,
    required this.batteryLevel,
    required this.status,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'smart_toy',
              color: isConnected ? Colors.blue : Colors.grey,
              size: 32,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'battery_charging_full',
                color: _getBatteryColor(batteryLevel),
                size: 14,
              ),
              SizedBox(width: 0.5.w),
              Text(
                '${batteryLevel.toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getBatteryColor(batteryLevel),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
}
