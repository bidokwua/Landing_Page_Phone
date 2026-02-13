import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying firmware update information and controls.
/// Shows current version, available updates, and download progress.
class FirmwareUpdateWidget extends StatefulWidget {
  final Map<String, dynamic> firmwareInfo;

  const FirmwareUpdateWidget({super.key, required this.firmwareInfo});

  @override
  State<FirmwareUpdateWidget> createState() => _FirmwareUpdateWidgetState();
}

class _FirmwareUpdateWidgetState extends State<FirmwareUpdateWidget> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  void _startUpdate() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Simulate download progress
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isDownloading) {
        setState(() => _downloadProgress = 0.3);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isDownloading) {
        setState(() => _downloadProgress = 0.6);
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isDownloading) {
        setState(() {
          _downloadProgress = 1.0;
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firmware update downloaded. Install when ready.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUpdate =
        widget.firmwareInfo["currentVersion"] !=
        widget.firmwareInfo["availableVersion"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Text(
            'Firmware Updates',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'system_update',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Current Version',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  widget.firmwareInfo["currentVersion"] as String,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              hasUpdate ? const Divider() : const SizedBox.shrink(),
              hasUpdate
                  ? Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF27AE60,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF27AE60),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Update Available',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF27AE60),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'v${widget.firmwareInfo["availableVersion"]}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Size: ${widget.firmwareInfo["updateSize"]}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Release Notes:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            widget.firmwareInfo["releaseNotes"] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                          SizedBox(height: 2.h),
                          _isDownloading
                              ? Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: _downloadProgress,
                                      backgroundColor: theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      '${(_downloadProgress * 100).toInt()}% downloaded',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  onPressed: _startUpdate,
                                  icon: CustomIconWidget(
                                    iconName: 'download',
                                    color: theme.colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                  label: const Text('Download Update'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 6.h),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const Divider(),
              SwitchListTile(
                title: Text(
                  'Automatic Updates',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Download updates automatically',
                  style: theme.textTheme.bodySmall,
                ),
                value: widget.firmwareInfo["autoUpdateEnabled"] as bool,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
