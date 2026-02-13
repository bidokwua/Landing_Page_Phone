import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MapControlsWidget extends StatelessWidget {
  final bool isDrawingMode;
  final String drawingZoneType;
  final VoidCallback onCenterRobot;
  final Function(String) onToggleDrawing;

  const MapControlsWidget({
    super.key,
    required this.isDrawingMode,
    required this.drawingZoneType,
    required this.onCenterRobot,
    required this.onToggleDrawing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(1.h),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            context: context,
            icon: 'block',
            label: 'No-Go',
            isActive: isDrawingMode && drawingZoneType == 'no-go',
            color: Colors.red,
            onTap: () => onToggleDrawing('no-go'),
          ),
          SizedBox(width: 1.w),
          _buildControlButton(
            context: context,
            icon: 'star',
            label: 'Priority',
            isActive: isDrawingMode && drawingZoneType == 'priority',
            color: Colors.green,
            onTap: () => onToggleDrawing('priority'),
          ),
          SizedBox(width: 1.w),
          _buildControlButton(
            context: context,
            icon: 'gps_fixed',
            label: 'Center',
            isActive: false,
            color: theme.colorScheme.primary,
            onTap: onCenterRobot,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required String icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : theme.colorScheme.outline,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isActive ? color : theme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? color : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
