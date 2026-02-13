import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TelemetryOverlayWidget extends StatelessWidget {
  final Map<String, dynamic> telemetryData;
  final bool isInspectMode;

  const TelemetryOverlayWidget({
    super.key,
    required this.telemetryData,
    required this.isInspectMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Top telemetry cards
        Positioned(
          top: 2.h,
          left: 4.w,
          right: 4.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryCard(
                context,
                icon: 'battery_charging_full',
                label: 'Battery',
                value: '${telemetryData["battery"]}%',
                color: _getBatteryColor(telemetryData["battery"] as int),
              ),
              _buildTelemetryCard(
                context,
                icon: 'signal_cellular_alt',
                label: 'Signal',
                value: '${telemetryData["connectionStrength"]}/5',
                color: _getSignalColor(
                  telemetryData["connectionStrength"] as int,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10.h,
          left: 4.w,
          right: 4.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryCard(
                context,
                icon: 'thermostat',
                label: 'Temp',
                value: '${telemetryData["temperature"]}°F',
                color: _getTemperatureColor(
                  telemetryData["temperature"] as double,
                ),
              ),
              _buildTelemetryCard(
                context,
                icon: 'air',
                label: 'Smoke',
                value: '${telemetryData["smokeIndex"]} AQI',
                color: _getSmokeColor(telemetryData["smokeIndex"] as int),
              ),
            ],
          ),
        ),

        // Inspect mode indicator
        if (isInspectMode)
          Positioned(
            bottom: 2.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'touch_app',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Tap to place waypoint',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTelemetryCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 20),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int battery) {
    if (battery > 50) return const Color(0xFF27AE60);
    if (battery > 20) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  Color _getSignalColor(int signal) {
    if (signal >= 4) return const Color(0xFF27AE60);
    if (signal >= 2) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 80) return const Color(0xFF27AE60);
    if (temp < 100) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  Color _getSmokeColor(int smoke) {
    if (smoke < 50) return const Color(0xFF27AE60);
    if (smoke < 100) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }
}
