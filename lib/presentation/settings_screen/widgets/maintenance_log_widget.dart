import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Widget for displaying a maintenance log entry.
/// Shows maintenance type, date, description, and status.
class MaintenanceLogWidget extends StatelessWidget {
  final Map<String, dynamic> log;

  const MaintenanceLogWidget({super.key, required this.log});

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF27AE60);
      case 'Upcoming':
        return const Color(0xFF3498DB);
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Inspection':
        return Icons.search;
      case 'Scheduled':
        return Icons.schedule;
      default:
        return Icons.build;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(log["status"] as String, theme);
    final typeIcon = _getTypeIcon(log["type"] as String);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: statusColor, size: 24),
        ),
        title: Text(
          log["type"] as String,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0.5.h),
            Text(
              log["description"] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Text(
                  _formatDate(log["date"] as DateTime),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '•',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  log["performedBy"] as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Text(
            log["status"] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                log["type"] as String,
                style: theme.textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${_formatDate(log["date"] as DateTime)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Performed by: ${log["performedBy"]}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Status: ${log["status"]}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Description:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    log["description"] as String,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
