import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EventDetailsSheetWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onClose;

  const EventDetailsSheetWidget({
    super.key,
    required this.event,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHeatEvent = event["type"] == "heat";
    final eventColor = isHeatEvent ? Colors.orange : Colors.red;
    final timestamp = event["timestamp"] as DateTime;

    return Container(
      margin: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: eventColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.h),
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: isHeatEvent ? 'local_fire_department' : 'cloud',
                    color: eventColor,
                    size: 32,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHeatEvent ? 'Heat Detection' : 'Smoke Detection',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.h),
            child: Column(
              children: [
                _buildDetailRow(
                  context: context,
                  icon: 'location_on',
                  label: 'Location',
                  value:
                      '${(event["location"] as dynamic).latitude.toStringAsFixed(6)}, ${(event["location"] as dynamic).longitude.toStringAsFixed(6)}',
                ),
                SizedBox(height: 1.5.h),
                _buildDetailRow(
                  context: context,
                  icon: 'warning',
                  label: 'Severity',
                  value: (event["severity"] as String).toUpperCase(),
                  valueColor: _getSeverityColor(event["severity"] as String),
                ),
                SizedBox(height: 1.5.h),
                isHeatEvent
                    ? _buildDetailRow(
                        context: context,
                        icon: 'thermostat',
                        label: 'Temperature',
                        value: '${event["temperature"]}°F',
                        valueColor: Colors.orange,
                      )
                    : _buildDetailRow(
                        context: context,
                        icon: 'air',
                        label: 'Smoke Index',
                        value: '${event["smokeIndex"]}/10',
                        valueColor: Colors.red,
                      ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          onClose();
                          // Navigate to robot
                        },
                        icon: CustomIconWidget(
                          iconName: 'navigation',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: const Text('Send Robot'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onClose();
                          // View camera
                        },
                        icon: CustomIconWidget(
                          iconName: 'videocam',
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                        label: const Text('View Camera'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
