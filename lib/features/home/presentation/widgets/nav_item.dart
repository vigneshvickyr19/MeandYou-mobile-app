import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class NavItem extends StatelessWidget {
  final int index;
  final String label;
  final String iconPath;
  final bool isActive;
  final ValueChanged<int> onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ICON
            SvgPicture.asset(
              iconPath,
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primary : Colors.white54,
                BlendMode.srcIn,
              ),
            ),

            /// LABEL (animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
