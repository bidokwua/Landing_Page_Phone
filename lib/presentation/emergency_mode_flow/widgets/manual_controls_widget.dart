import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Manual Controls Widget
/// Constrained manual controls with simplified interface requiring continuous hold-to-drive
class ManualControlsWidget extends StatelessWidget {
  final bool isExpanded;
  final String? activeDirection;
  final VoidCallback onToggleExpanded;
  final Function(String) onDirectionControl;

  const ManualControlsWidget({
    super.key,
    required this.isExpanded,
    required this.activeDirection,
    required this.onToggleExpanded,
    required this.onDirectionControl,
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
                    iconName: 'gamepad',
                    color: theme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Controls',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Hold to drive - auto timeout 5s',
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
                  // Directional Pad
                  SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: Stack(
                      children: [
                        // Up
                        Positioned(
                          top: 0,
                          left: 20.w,
                          child: _buildDirectionButton(
                            context,
                            theme,
                            'forward',
                            Icons.arrow_upward,
                          ),
                        ),
                        // Down
                        Positioned(
                          bottom: 0,
                          left: 20.w,
                          child: _buildDirectionButton(
                            context,
                            theme,
                            'backward',
                            Icons.arrow_downward,
                          ),
                        ),
                        // Left
                        Positioned(
                          top: 20.w,
                          left: 0,
                          child: _buildDirectionButton(
                            context,
                            theme,
                            'left',
                            Icons.arrow_back,
                          ),
                        ),
                        // Right
                        Positioned(
                          top: 20.w,
                          right: 0,
                          child: _buildDirectionButton(
                            context,
                            theme,
                            'right',
                            Icons.arrow_forward,
                          ),
                        ),
                        // Center Stop
                        Positioned(
                          top: 20.w,
                          left: 20.w,
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'stop',
                                color: Colors.white,
                                size: 8.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Camera Pan Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCameraButton(
                        context,
                        theme,
                        'Pan Left',
                        Icons.rotate_left,
                      ),
                      _buildCameraButton(
                        context,
                        theme,
                        'Center',
                        Icons.center_focus_strong,
                      ),
                      _buildCameraButton(
                        context,
                        theme,
                        'Pan Right',
                        Icons.rotate_right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDirectionButton(
    BuildContext context,
    ThemeData theme,
    String direction,
    IconData icon,
  ) {
    final isActive = activeDirection == direction;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        onDirectionControl(direction);
      },
      onTapUp: (_) {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon.codePoint.toString(),
            color: isActive ? Colors.white : theme.colorScheme.primary,
            size: 8.w,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton(
    BuildContext context,
    ThemeData theme,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon.codePoint.toString(),
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
