import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData iconData;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.success;
        iconData = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.error;
        iconData = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = AppColors.warning;
        iconData = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = AppColors.info;
        iconData = Icons.info;
        break;
    }

    final overlay = OverlayEntry(
      builder: (_) => _TopAnimatedSnackbar(
        message: message,
        icon: iconData,
        backgroundColor: backgroundColor,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(overlay);

    Future.delayed(duration + const Duration(milliseconds: 400), () {
      overlay.remove();
    });
  }
}

class _TopAnimatedSnackbar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;

  const _TopAnimatedSnackbar({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.actionLabel,
    this.onAction,
    required this.duration,
  });

  @override
  State<_TopAnimatedSnackbar> createState() => _TopAnimatedSnackbarState();
}

class _TopAnimatedSnackbarState extends State<_TopAnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0), // from top
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: AppColors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onAction != null)
                    TextButton(
                      onPressed: widget.onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(widget.actionLabel!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
