import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/firmware_update_widget.dart';
import './widgets/household_user_card_widget.dart';
import './widgets/maintenance_log_widget.dart';
import './widgets/safety_lock_widget.dart';
import './widgets/settings_section_widget.dart';

/// Settings Screen for Firefly Defender application.
/// Manages household access, device configuration, and safety controls.
///
/// Features:
/// - Household user management with role-based permissions
/// - Wi-Fi and robot connectivity settings
/// - Firmware update management
/// - Safety locks configuration (PIN, child lock, geofence)
/// - Maintenance logs and cleaning checklists
/// - Privacy settings for camera and data
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3; // Settings tab index

  // Mock data for household users
  final List<Map<String, dynamic>> _householdUsers = [
    {
      "id": 1,
      "name": "Sarah Mitchell",
      "email": "sarah.mitchell@email.com",
      "role": "Owner",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_149f3bcac-1763298667408.png",
      "semanticLabel":
          "Profile photo of a woman with shoulder-length brown hair wearing a blue shirt",
      "permissions": {
        "fullControl": true,
        "emergencyMode": true,
        "manualControl": true,
        "viewOnly": false,
      },
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "email": "michael.chen@email.com",
      "role": "Monitor",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a gray sweater",
      "permissions": {
        "fullControl": false,
        "emergencyMode": true,
        "manualControl": false,
        "viewOnly": false,
      },
    },
    {
      "id": 3,
      "name": "Emma Rodriguez",
      "email": "emma.rodriguez@email.com",
      "role": "Guest",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_176e07230-1763293461602.png",
      "semanticLabel":
          "Profile photo of a woman with long dark hair wearing a white top",
      "permissions": {
        "fullControl": false,
        "emergencyMode": false,
        "manualControl": false,
        "viewOnly": true,
      },
    },
  ];

  // Mock data for firmware
  final Map<String, dynamic> _firmwareInfo = {
    "currentVersion": "2.4.1",
    "availableVersion": "2.5.0",
    "updateSize": "45.2 MB",
    "releaseDate": "2026-02-01",
    "releaseNotes":
        "• Improved heat detection accuracy\n• Enhanced battery optimization\n• Bug fixes and performance improvements",
    "autoUpdateEnabled": true,
    "downloadProgress": 0.0,
  };

  // Mock data for maintenance logs
  final List<Map<String, dynamic>> _maintenanceLogs = [
    {
      "id": 1,
      "date": DateTime(2026, 1, 28),
      "type": "Cleaning",
      "description": "Sensor cleaning and filter replacement",
      "performedBy": "Sarah Mitchell",
      "status": "Completed",
    },
    {
      "id": 2,
      "date": DateTime(2026, 1, 15),
      "type": "Inspection",
      "description": "Quarterly system inspection",
      "performedBy": "Firefly Service Team",
      "status": "Completed",
    },
    {
      "id": 3,
      "date": DateTime(2026, 2, 15),
      "type": "Scheduled",
      "description": "Battery health check",
      "performedBy": "Pending",
      "status": "Upcoming",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/home-dashboard');
        break;
      case 1:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/map-screen');
        break;
      case 2:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/camera-screen');
        break;
      case 3:
        // Already on settings screen
        break;
    }
  }

  void _showAddUserDialog() {
    final theme = Theme.of(context);
    final emailController = TextEditingController();
    String selectedRole = "Monitor";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite User', style: theme.textTheme.titleLarge),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'user@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              Text('Permission Level', style: theme.textTheme.titleSmall),
              SizedBox(height: 1.h),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Owner', 'Monitor', 'Guest'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedRole = value!);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invitation sent to ${emailController.text}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _showPermissionEditor(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    Map<String, bool> permissions = Map.from(
      user["permissions"] as Map<String, dynamic>,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Permissions', style: theme.textTheme.titleLarge),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Full Control'),
                subtitle: const Text('Complete robot access'),
                value: permissions["fullControl"] ?? false,
                onChanged: (value) {
                  setDialogState(() => permissions["fullControl"] = value);
                },
              ),
              SwitchListTile(
                title: const Text('Emergency Mode'),
                subtitle: const Text('Activate emergency protocols'),
                value: permissions["emergencyMode"] ?? false,
                onChanged: (value) {
                  setDialogState(() => permissions["emergencyMode"] = value);
                },
              ),
              SwitchListTile(
                title: const Text('Manual Control'),
                subtitle: const Text('Direct robot operation'),
                value: permissions["manualControl"] ?? false,
                onChanged: (value) {
                  setDialogState(() => permissions["manualControl"] = value);
                },
              ),
              SwitchListTile(
                title: const Text('View Only'),
                subtitle: const Text('Monitor without control'),
                value: permissions["viewOnly"] ?? false,
                onChanged: (value) {
                  setDialogState(() => permissions["viewOnly"] = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                user["permissions"] = permissions;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permissions updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeUser(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove User', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to remove ${user["name"]} from household access?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _householdUsers.removeWhere((u) => u["id"] == user["id"]);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user["name"]} removed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Settings',
        variant: CustomAppBarVariant.standard,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Users'),
                    Tab(text: 'Device'),
                    Tab(text: 'Safety'),
                    Tab(text: 'Privacy'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersTab(theme),
                    _buildDeviceTab(theme),
                    _buildSafetyTab(theme),
                    _buildPrivacyTab(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: CustomBottomBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _handleBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
    return ListView(
      children: [
        SettingsSectionWidget(
          title: 'Household Users',
          children: [
            ..._householdUsers.map(
              (user) => HouseholdUserCardWidget(
                user: user,
                onTap: () => _showPermissionEditor(user),
                onRemove: () => _removeUser(user),
              ),
            ),
            SizedBox(height: 1.h),
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceTab(ThemeData theme) {
    return ListView(
      children: [
        SettingsSectionWidget(
          title: 'Wi-Fi Connectivity',
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'wifi',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Home Network', style: theme.textTheme.titleMedium),
              subtitle: Text(
                'Connected • Signal: Strong',
                style: theme.textTheme.bodySmall,
              ),
              trailing: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Wi-Fi settings...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Change'),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SettingsSectionWidget(
          title: 'Robot Connection',
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings_remote',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Firefly Unit #FF-2401',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Paired • Last sync: 2 min ago',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Divider(),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Re-pair Device', style: theme.textTheme.titleMedium),
              subtitle: Text(
                'Scan QR code to reconnect',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening QR scanner...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 2.h),
        FirmwareUpdateWidget(firmwareInfo: _firmwareInfo),
      ],
    );
  }

  Widget _buildSafetyTab(ThemeData theme) {
    return ListView(
      children: [
        SafetyLockWidget(),
        SizedBox(height: 2.h),
        SettingsSectionWidget(
          title: 'Maintenance',
          children: [
            ..._maintenanceLogs.map((log) => MaintenanceLogWidget(log: log)),
            SizedBox(height: 1.h),
            OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening maintenance scheduler...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Schedule Maintenance'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacyTab(ThemeData theme) {
    return ListView(
      children: [
        SettingsSectionWidget(
          title: 'Camera & Recording',
          children: [
            SwitchListTile(
              title: Text(
                'Auto-delete recordings',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Delete after 30 days',
                style: theme.textTheme.bodySmall,
              ),
              value: true,
              onChanged: (value) {
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'storage',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Storage Usage', style: theme.textTheme.titleMedium),
              subtitle: Text(
                '2.4 GB of 10 GB used',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SettingsSectionWidget(
          title: 'Data Sharing',
          children: [
            SwitchListTile(
              title: Text(
                'Share usage analytics',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Help improve Firefly',
                style: theme.textTheme.bodySmall,
              ),
              value: true,
              onChanged: (value) {
                HapticFeedback.lightImpact();
              },
            ),
            SwitchListTile(
              title: Text(
                'Emergency data sharing',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Share with fire services during emergencies',
                style: theme.textTheme.bodySmall,
              ),
              value: true,
              onChanged: (value) {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SettingsSectionWidget(
          title: 'Account',
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Download my data',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Export all account data',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preparing data export...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_forever',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete account',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              subtitle: Text(
                'Permanently remove all data',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                HapticFeedback.mediumImpact();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Delete Account',
                      style: theme.textTheme.titleLarge,
                    ),
                    content: Text(
                      'This action cannot be undone. All your data, including robot pairing and recordings, will be permanently deleted.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account deletion initiated'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
