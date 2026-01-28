import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import 'nav_item.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 25),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
