import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Emergency Contacts Widget
/// Auto-notification panel and emergency contact calling with one-tap dialing
class EmergencyContactsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> emergencyContacts;
  final List<Map<String, dynamic>> autoNotifications;
  final Function(Map<String, dynamic>) onCallContact;

  const EmergencyContactsWidget({
    super.key,
    required this.emergencyContacts,
    required this.autoNotifications,
    required this.onCallContact,
  });

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
            'Emergency Contacts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          // Emergency Contacts List
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: emergencyContacts.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final contact = emergencyContacts[index];
              return _buildContactCard(context, theme, contact);
            },
          ),
          SizedBox(height: 2.h),

          // Auto-Notifications Section
          Text(
            'Auto-Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: autoNotifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final notification = autoNotifications[index];
              return _buildNotificationCard(context, theme, notification);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> contact,
  ) {
    final isNotified = contact['notified'] == true;
    final contactType = contact['type'] as String;

    Color getTypeColor() {
      if (contactType == 'emergency') return const Color(0xFFE74C3C);
      if (contactType == 'family') return const Color(0xFF3498DB);
      return const Color(0xFF27AE60);
    }

    IconData getTypeIcon() {
      if (contactType == 'emergency') return Icons.local_fire_department;
      if (contactType == 'family') return Icons.family_restroom;
      return Icons.people;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: getTypeColor().withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: getTypeIcon().codePoint.toString(),
                color: getTypeColor(),
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  contact['phone'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isNotified && contact['timestamp'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: const Color(0xFF27AE60),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Notified ${_formatTimestamp(contact['timestamp'])}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onCallContact(contact),
            style: ElevatedButton.styleFrom(
              backgroundColor: getTypeColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'phone',
                  color: Colors.white,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text('Call'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> notification,
  ) {
    final status = notification['status'] as String;
    final isDelivered = status == 'delivered';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDelivered
            ? const Color(0xFF27AE60).withValues(alpha: 0.1)
            : const Color(0xFFF39C12).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDelivered
              ? const Color(0xFF27AE60)
              : const Color(0xFFF39C12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isDelivered ? 'check_circle' : 'schedule',
            color: isDelivered
                ? const Color(0xFF27AE60)
                : const Color(0xFFF39C12),
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['message'],
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(notification['timestamp']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
