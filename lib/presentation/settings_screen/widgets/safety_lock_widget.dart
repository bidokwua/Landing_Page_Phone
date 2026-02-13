import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for configuring safety locks and security settings.
/// Includes PIN setup, child lock, and geofence configuration.
class SafetyLockWidget extends StatefulWidget {
  const SafetyLockWidget({super.key});

  @override
  State<SafetyLockWidget> createState() => _SafetyLockWidgetState();
}

class _SafetyLockWidgetState extends State<SafetyLockWidget> {
  bool _pinEnabled = true;
  bool _childLockEnabled = false;
  bool _geofenceEnabled = true;

  void _showPinSetup() {
    final theme = Theme.of(context);
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set PIN', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'Enter 4-digit PIN',
                hintText: '0000',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            SizedBox(height: 1.h),
            Text(
              'This PIN will be required for emergency mode and critical actions.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN updated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGeofenceEditor() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening geofence editor...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Text(
            'Safety Locks',
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
              SwitchListTile(
                title: Text(
                  'PIN Protection',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Require PIN for critical actions',
                  style: theme.textTheme.bodySmall,
                ),
                value: _pinEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() => _pinEnabled = value);
                },
                secondary: CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              _pinEnabled
                  ? ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      title: Text(
                        'Change PIN',
                        style: theme.textTheme.titleSmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showPinSetup,
                    )
                  : const SizedBox.shrink(),
              const Divider(),
              SwitchListTile(
                title: Text('Child Lock', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Prevent accidental activation',
                  style: theme.textTheme.bodySmall,
                ),
                value: _childLockEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() => _childLockEnabled = value);
                },
                secondary: CustomIconWidget(
                  iconName: 'child_care',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: Text('Geofence', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Restrict robot to property boundaries',
                  style: theme.textTheme.bodySmall,
                ),
                value: _geofenceEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() => _geofenceEnabled = value);
                },
                secondary: CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              _geofenceEnabled
                  ? ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      title: Text(
                        'Edit Geofence',
                        style: theme.textTheme.titleSmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showGeofenceEditor,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
