import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import 'nav_item.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final bool showAdmin;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.showAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isWideScreen = size.width > 600;

    // Responsive dimensions
    final double navHeight = isSmallScreen ? 64 : 76;
    final double horizontalMargin = isWideScreen ? size.width * 0.2 : 16;
    final double bottomMargin = isSmallScreen ? 16 : 28;
    final bool hideLabels = isSmallScreen;

    return Container(
      height: navHeight,
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.navBg,
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A2A),
            AppColors.navBg,
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            index: 0,
            label: 'Home',
            iconPath: AppImages.homeIcon,
            isActive: currentIndex == 0,
            onTap: onChanged,
            showLabel: !hideLabels,
          ),
          NavItem(
            index: 1,
            label: 'Likes',
            iconPath: AppImages.lovelyIcon,
            isActive: currentIndex == 1,
            onTap: onChanged,
            showLabel: !hideLabels,
          ),
          if (showAdmin)
            NavItem(
              index: 4,
              label: 'Admin',
              iconPath: AppImages.homeIcon, // Temporary fallback
              icon: Icons.admin_panel_settings_rounded,
              isActive: currentIndex == 4,
              onTap: onChanged,
              showLabel: !hideLabels,
            ),
          NavItem(
            index: 2,
            label: 'Chats',
            iconPath: AppImages.messageIcon,
            isActive: currentIndex == 2,
            onTap: onChanged,
            showLabel: !hideLabels,
          ),
          NavItem(
            index: 3,
            label: 'Profile',
            iconPath: AppImages.profileIcon,
            isActive: currentIndex == 3,
            onTap: onChanged,
            showLabel: !hideLabels,
          ),
        ],
      ),
    );
  }
}
