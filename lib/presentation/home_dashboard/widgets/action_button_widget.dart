import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonWidget extends StatefulWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onPressed;
  final bool requiresHold;

  const ActionButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.requiresHold = false,
  });

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  bool _isPressed = false;
  double _holdProgress = 0.0;

  void _handleTapDown(TapDownDetails details) {
    if (widget.requiresHold) {
      setState(() => _isPressed = true);
      _startHoldTimer();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.requiresHold) {
      setState(() {
        _isPressed = false;
        _holdProgress = 0.0;
      });
    }
  }

  void _handleTapCancel() {
    if (widget.requiresHold) {
      setState(() {
        _isPressed = false;
        _holdProgress = 0.0;
      });
    }
  }

  void _startHoldTimer() async {
    const duration = Duration(milliseconds: 50);
    const totalSteps = 30;

    for (int i = 0; i < totalSteps && _isPressed; i++) {
      await Future.delayed(duration);
      if (_isPressed) {
        setState(() {
          _holdProgress = (i + 1) / totalSteps;
        });
      }
    }

    if (_isPressed && _holdProgress >= 1.0) {
      HapticFeedback.heavyImpact();
      widget.onPressed();
      setState(() {
        _isPressed = false;
        _holdProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.requiresHold) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: double.infinity,
          height: 7.h,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              if (_holdProgress > 0)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _holdProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _isPressed ? 'Hold to Confirm...' : widget.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: widget.icon,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              widget.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
