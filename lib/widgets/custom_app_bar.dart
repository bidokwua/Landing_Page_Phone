import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar variants for wildfire defense application.
/// Implements contextual app bar that adapts content and actions
/// based on current robot status and screen context.
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button for navigation
  withBackButton,

  /// App bar with status indicator for robot connection
  withStatus,

  /// Emergency mode app bar with high contrast
  emergency,
}

/// Custom app bar for wildfire defense application.
/// Provides consistent navigation and context-aware actions
/// optimized for emergency operations and outdoor visibility.
///
/// Features:
/// - Contextual actions based on screen state
/// - Robot status indicators for monitoring
/// - Emergency mode styling for critical situations
/// - Large touch targets for reliable interaction
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// App bar variant determining layout and styling
  final CustomAppBarVariant variant;

  /// Optional leading widget (overrides default back button)
  final Widget? leading;

  /// Optional action widgets displayed on the right
  final List<Widget>? actions;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Robot connection status (for withStatus variant)
  final bool? isConnected;

  /// Whether to show emergency styling
  final bool isEmergencyMode;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.onBackPressed,
    this.isConnected,
    this.isEmergencyMode = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Emergency mode colors
    final backgroundColor = isEmergencyMode
        ? const Color(0xFFE74C3C)
        : theme.appBarTheme.backgroundColor;
    final foregroundColor = isEmergencyMode
        ? Colors.white
        : theme.appBarTheme.foregroundColor;

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark || isEmergencyMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDark || isEmergencyMode
            ? Brightness.dark
            : Brightness.light,
      ),
      leading: _buildLeading(context, foregroundColor),
      title: _buildTitle(context, foregroundColor),
      actions: _buildActions(context, foregroundColor),
    );
  }

  Widget? _buildLeading(BuildContext context, Color? foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (variant == CustomAppBarVariant.withBackButton ||
        variant == CustomAppBarVariant.emergency) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 24,
        color: foregroundColor,
        tooltip: 'Back',
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }

    return null;
  }

  Widget _buildTitle(BuildContext context, Color? foregroundColor) {
    final theme = Theme.of(context);

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foregroundColor?.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: foregroundColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (variant == CustomAppBarVariant.withStatus &&
            isConnected != null) ...[
          const SizedBox(width: 12),
          _buildStatusIndicator(context, foregroundColor),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Color? foregroundColor) {
    final statusColor = isConnected!
        ? const Color(0xFF27AE60)
        : const Color(0xFFF39C12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isConnected! ? 'Connected' : 'Offline',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, Color? foregroundColor) {
    if (actions != null && actions!.isNotEmpty) {
      return actions!.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            iconSize: 24,
            color: foregroundColor,
            tooltip: action.tooltip,
            onPressed: () {
              HapticFeedback.lightImpact();
              action.onPressed?.call();
            },
          );
        }
        return action;
      }).toList();
    }

    return null;
  }
}
