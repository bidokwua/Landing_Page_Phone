import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ZoneDrawingControlsWidget extends StatelessWidget {
  final int pointCount;
  final String zoneType;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const ZoneDrawingControlsWidget({
    super.key,
    required this.pointCount,
    required this.zoneType,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zoneColor = zoneType == 'no-go' ? Colors.red : Colors.green;

    return Container(
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(1.5.h),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: zoneColor, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: zoneType == 'no-go' ? 'block' : 'star',
                  color: zoneColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drawing ${zoneType == 'no-go' ? 'No-Go' : 'Priority'} Zone',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: zoneColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$pointCount point${pointCount != 1 ? 's' : ''} placed (min 3 required)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pointCount >= 3 ? onComplete : null,
                  icon: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: zoneColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap on map to add points. Need at least 3 points to complete zone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
