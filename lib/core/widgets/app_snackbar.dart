import 'dart:ui';
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
    String emoji;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.success;
        iconData = Icons.check_circle;
        emoji = '✨';
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.error;
        iconData = Icons.error;
        emoji = '😢';
        break;
      case SnackbarType.warning:
        backgroundColor = AppColors.warning;
        iconData = Icons.warning;
        emoji = '⚠️';
        break;
      case SnackbarType.info:
        backgroundColor = AppColors.info;
        iconData = Icons.info;
        emoji = '💡';
        break;
    }

    final overlay = OverlayEntry(
      builder: (_) => _TopAnimatedSnackbar(
        message: '$emoji $message',
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
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0), // from top
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

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
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: AppColors.white, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null && widget.onAction != null)
                        TextButton(
                          onPressed: widget.onAction,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
