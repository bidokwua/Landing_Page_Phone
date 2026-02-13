import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MaintenanceCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;

  const MaintenanceCardWidget({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = task["title"] as String;
    final dueDate = task["dueDate"] as String;
    final priority = task["priority"] as String;
    final description = task["description"] as String;
    final isCompleted = task["isCompleted"] as bool;

    Color getPriorityColor() {
      switch (priority) {
        case "high":
          return const Color(0xFFE74C3C);
        case "medium":
          return const Color(0xFFF39C12);
        case "low":
          return const Color(0xFF3498DB);
        default:
          return theme.colorScheme.primary;
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                        : getPriorityColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: isCompleted ? 'check_circle' : 'build',
                    color: isCompleted
                        ? const Color(0xFF27AE60)
                        : getPriorityColor(),
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Due: $dueDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: getPriorityColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: getPriorityColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!isCompleted) ...[
              SizedBox(height: 1.5.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onComplete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFF27AE60),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'check',
                        color: const Color(0xFF27AE60),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Mark as Complete',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF27AE60),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
