import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DiscoverActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLike;
  final Color? color;

  const DiscoverActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLike = false,
    this.color,
  });

  @override
  State<DiscoverActionButton> createState() => _DiscoverActionButtonState();
}

class _DiscoverActionButtonState extends State<DiscoverActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _animationController.forward();
    await _animationController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = widget.isLike ? AppColors.primary : Colors.white;
    final iconColor = widget.color ?? defaultColor;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isLike ? AppColors.primary : Colors.black)
                        .withValues(alpha: widget.isLike ? 0.3 : 0.5),
                    blurRadius: 15 + _glowAnimation.value,
                    spreadRadius: _glowAnimation.value / 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.isLike ? AppColors.primary : Colors.white)
                            .withValues(alpha: 0.2 + (_animationController.value * 0.3)),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: iconColor,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
