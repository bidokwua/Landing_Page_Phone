import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ControlBarWidget extends StatelessWidget {
  final bool isRecording;
  final bool isInspectMode;
  final String recordingDuration;
  final VoidCallback onCapturePhoto;
  final VoidCallback onToggleRecording;
  final VoidCallback onToggleInspectMode;

  const ControlBarWidget({
    super.key,
    required this.isRecording,
    required this.isInspectMode,
    required this.recordingDuration,
    required this.onCapturePhoto,
    required this.onToggleRecording,
    required this.onToggleInspectMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            context,
            icon: 'camera_alt',
            label: 'Snapshot',
            onPressed: onCapturePhoto,
            color: theme.colorScheme.primary,
          ),
          _buildControlButton(
            context,
            icon: isRecording ? 'stop' : 'fiber_manual_record',
            label: isRecording ? recordingDuration : 'Record',
            onPressed: onToggleRecording,
            color: isRecording
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            isActive: isRecording,
          ),
          _buildControlButton(
            context,
            icon: 'explore',
            label: 'Inspect',
            onPressed: onToggleInspectMode,
            color: theme.colorScheme.tertiary,
            isActive: isInspectMode,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : theme.colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isActive ? color : theme.colorScheme.onSurface,
              size: 28,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive ? color : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
