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
    return Container(
      height: 76,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
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
          ),
          NavItem(
            index: 1,
            label: 'Likes',
            iconPath: AppImages.lovelyIcon,
            isActive: currentIndex == 1,
            onTap: onChanged,
          ),
          if (showAdmin)
            NavItem(
              index: 4,
              label: 'Admin',
              iconPath: AppImages.homeIcon, // Temporary fallback
              icon: Icons.admin_panel_settings_rounded,
              isActive: currentIndex == 4,
              onTap: onChanged,
            ),
          NavItem(
            index: 2,
            label: 'Chats',
            iconPath: AppImages.messageIcon,
            isActive: currentIndex == 2,
            onTap: onChanged,
          ),
          NavItem(
            index: 3,
            label: 'Profile',
            iconPath: AppImages.profileIcon,
            isActive: currentIndex == 3,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}
