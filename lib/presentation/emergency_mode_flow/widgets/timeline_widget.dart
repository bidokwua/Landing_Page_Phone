import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Timeline Widget
/// Step-by-step timeline showing verification sequence, defend actions, and return conditions
class TimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timelineSteps;

  const TimelineWidget({super.key, required this.timelineSteps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mission Timeline',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: timelineSteps.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final step = timelineSteps[index];
              return _buildTimelineStep(context, theme, step, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> step,
    int index,
  ) {
    final isCompleted = step['completed'] == true;
    final hasTimestamp = step['timestamp'] != null;
    final hasEstimatedTime = step['estimatedTime'] != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Indicator
        Column(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF27AE60)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF27AE60)
                      : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 5.w,
                      )
                    : Text(
                        '${index + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (index < timelineSteps.length - 1)
              Container(
                width: 2,
                height: 6.h,
                color: isCompleted
                    ? const Color(0xFF27AE60)
                    : theme.colorScheme.outline,
              ),
          ],
        ),
        SizedBox(width: 3.w),

        // Step Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                step['description'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (hasTimestamp) ...[
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(step['timestamp']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF27AE60),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (hasEstimatedTime && !isCompleted) ...[
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF39C12).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Est. ${step['estimatedTime']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF39C12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
    }
  }
}
