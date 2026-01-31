import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SegmentedTabHeader extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final VoidCallback? onNotificationTap;

  const SegmentedTabHeader({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          // Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab('Nearby', 0),
                const SizedBox(width: 4),
                _buildTab('Discover', 1),
              ],
            ),
          ),
          const Spacer(),
          // Notification Icon
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
            onPressed: onNotificationTap,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
