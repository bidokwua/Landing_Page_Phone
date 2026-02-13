import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RobotStatusCardWidget extends StatelessWidget {
  final Map<String, dynamic> robotStatus;
  final VoidCallback onTap;

  const RobotStatusCardWidget({
    super.key,
    required this.robotStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final battery = robotStatus["battery"] as int;
    final waterLevel = robotStatus["waterLevel"] as int;
    final powderLevel = robotStatus["powderLevel"] as int;
    final connectivity = robotStatus["connectivity"] as String;
    final status = robotStatus["status"] as String;
    final location = robotStatus["location"] as String;

    Color getBatteryColor() {
      if (battery > 60) return const Color(0xFF27AE60);
      if (battery > 30) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    }

    Color getLevelColor(int level) {
      if (level > 50) return const Color(0xFF27AE60);
      if (level > 25) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Robot Status', style: theme.textTheme.titleLarge),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: status == "Idle"
                          ? const Color(0xFF3498DB).withValues(alpha: 0.2)
                          : const Color(0xFF27AE60).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status == "Idle"
                            ? const Color(0xFF3498DB)
                            : const Color(0xFF27AE60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(location, style: theme.textTheme.bodyMedium),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: getBatteryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'battery_charging_full',
                              color: getBatteryColor(),
                              size: 24,
                            ),
                            SizedBox(width: 2.w),
                            Text('Battery', style: theme.textTheme.titleMedium),
                          ],
                        ),
                        Text(
                          '$battery%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: getBatteryColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    LinearPercentIndicator(
                      lineHeight: 8,
                      percent: battery / 100,
                      backgroundColor: theme.colorScheme.surface,
                      progressColor: getBatteryColor(),
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: getLevelColor(waterLevel).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'water_drop',
                            color: getLevelColor(waterLevel),
                            size: 32,
                          ),
                          SizedBox(height: 1.h),
                          Text('Water', style: theme.textTheme.bodySmall),
                          SizedBox(height: 0.5.h),
                          Text(
                            '$waterLevel%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: getLevelColor(waterLevel),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          LinearPercentIndicator(
                            lineHeight: 6,
                            percent: waterLevel / 100,
                            backgroundColor: theme.colorScheme.surface,
                            progressColor: getLevelColor(waterLevel),
                            barRadius: const Radius.circular(3),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: getLevelColor(
                          powderLevel,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'science',
                            color: getLevelColor(powderLevel),
                            size: 32,
                          ),
                          SizedBox(height: 1.h),
                          Text('Powder', style: theme.textTheme.bodySmall),
                          SizedBox(height: 0.5.h),
                          Text(
                            '$powderLevel%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: getLevelColor(powderLevel),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          LinearPercentIndicator(
                            lineHeight: 6,
                            percent: powderLevel / 100,
                            backgroundColor: theme.colorScheme.surface,
                            progressColor: getLevelColor(powderLevel),
                            barRadius: const Radius.circular(3),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'signal_cellular_alt',
                        color: connectivity == "Strong"
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF39C12),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Connectivity: $connectivity',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
