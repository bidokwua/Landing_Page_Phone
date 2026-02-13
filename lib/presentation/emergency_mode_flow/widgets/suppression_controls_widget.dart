import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Suppression Controls Widget
/// Double-confirmation pattern for water/powder release with countdown timer
class SuppressionControlsWidget extends StatelessWidget {
  final bool isExpanded;
  final bool waterSystemArmed;
  final bool powderSystemArmed;
  final int waterLevel;
  final int powderLevel;
  final VoidCallback onToggleExpanded;
  final Function(String) onArmSystem;
  final Function(String) onActivateSystem;

  const SuppressionControlsWidget({
    super.key,
    required this.isExpanded,
    required this.waterSystemArmed,
    required this.powderSystemArmed,
    required this.waterLevel,
    required this.powderLevel,
    required this.onToggleExpanded,
    required this.onArmSystem,
    required this.onActivateSystem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggleExpanded,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'water_drop',
                    color: const Color(0xFF3498DB),
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suppression Systems',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Double-confirm to activate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),

          // Controls
          if (isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Water System
                  _buildSuppressionSystem(
                    context,
                    theme,
                    'Water System',
                    'water',
                    waterSystemArmed,
                    waterLevel,
                    const Color(0xFF3498DB),
                    Icons.water_drop,
                  ),
                  SizedBox(height: 2.h),

                  // Powder System
                  _buildSuppressionSystem(
                    context,
                    theme,
                    'Powder System',
                    'powder',
                    powderSystemArmed,
                    powderLevel,
                    const Color(0xFFF39C12),
                    Icons.cloud,
                  ),
                  SizedBox(height: 2.h),

                  // Warning Message
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: theme.colorScheme.error,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Suppression activation requires double confirmation and hold gesture',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuppressionSystem(
    BuildContext context,
    ThemeData theme,
    String label,
    String system,
    bool isArmed,
    int level,
    Color systemColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: systemColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isArmed ? systemColor : theme.colorScheme.outline,
          width: isArmed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon.codePoint.toString(),
                color: systemColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Level: $level%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isArmed)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: systemColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ARMED',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),

          // Level Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level / 100,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(systemColor),
              minHeight: 1.h,
            ),
          ),
          SizedBox(height: 2.h),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onArmSystem(system);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isArmed
                        ? theme.colorScheme.surface
                        : systemColor,
                    foregroundColor: isArmed
                        ? theme.colorScheme.onSurface
                        : Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Text(isArmed ? 'DISARM' : 'ARM'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isArmed ? () => onActivateSystem(system) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    disabledBackgroundColor: theme.colorScheme.surface,
                    disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  child: Text('ACTIVATE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
