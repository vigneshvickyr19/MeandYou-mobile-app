import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';

class NavItem extends StatelessWidget {
  final int index;
  final String label;
  final String iconPath;
  final IconData? icon;
  final bool isActive;
  final ValueChanged<int> onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.label,
    required this.iconPath,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.navItemBg.withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Background Circle (Animates only when active)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isActive ? 10 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.navActiveGradientStart,
                          AppColors.navActiveGradientEnd,
                        ],
                      )
                    : null,
              ),
              child: icon != null 
                ? Icon(
                    icon,
                    size: 20,
                    color: isActive 
                        ? Colors.black 
                        : AppColors.navInactive, 
                  )
                : SvgPicture.asset(
                    iconPath,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      isActive 
                          ? Colors.black 
                          : AppColors.navInactive, 
                      BlendMode.srcIn,
                    ),
                  ),
            ),
    
            // Animated Label (Uses CrossFade for safe structural transition)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFFF8A3D),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              crossFadeState: isActive 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}
