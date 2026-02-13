import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Status Display Widget
/// Large status display showing current robot state with animated status icons
class StatusDisplayWidget extends StatelessWidget {
  final String currentStatus;
  final bool isDefending;
  final bool isReturning;
  final bool isOffline;
  final Map<String, dynamic> robotTelemetry;
  final Animation<double> statusPulseAnimation;

  const StatusDisplayWidget({
    super.key,
    required this.currentStatus,
    required this.isDefending,
    required this.isReturning,
    required this.isOffline,
    required this.robotTelemetry,
    required this.statusPulseAnimation,
  });

  Color _getStatusColor(BuildContext context) {
    if (isOffline) return Colors.grey;
    if (isDefending) return const Color(0xFFE74C3C);
    if (isReturning) return const Color(0xFF3498DB);
    return const Color(0xFFF39C12);
  }

  IconData _getStatusIcon() {
    if (isOffline) return Icons.cloud_off;
    if (isDefending) return Icons.shield;
    if (isReturning) return Icons.home;
    return Icons.search;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Status Icon
          ScaleTransition(
            scale: statusPulseAnimation,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getStatusIcon().codePoint.toString(),
                  color: Colors.white,
                  size: 10.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Status Text
          Text(
            currentStatus.toUpperCase(),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Status Description
          Text(
            _getStatusDescription(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Telemetry Grid
          _buildTelemetryGrid(theme),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    if (isOffline) return 'Connection lost - attempting to reconnect';
    if (isDefending) return 'Active defense operations in progress';
    if (isReturning) return 'Returning to home base';
    return 'Scanning property for threats';
  }

  Widget _buildTelemetryGrid(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildTelemetryCard(
            theme,
            'Battery',
            '${robotTelemetry['battery']}%',
            Icons.battery_charging_full,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildTelemetryCard(
            theme,
            'Water',
            '${robotTelemetry['waterLevel']}%',
            Icons.water_drop,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildTelemetryCard(
            theme,
            'Powder',
            '${robotTelemetry['powderLevel']}%',
            Icons.cloud,
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.codePoint.toString(),
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
