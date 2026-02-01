import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PillTabSwitcher extends StatelessWidget {
  final List<String> tabs;
  final TabController controller;

  const PillTabSwitcher({
    super.key,
    required this.tabs,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tabs.length, (index) {
                final isActive = controller.index == index;
                return _buildTab(
                  label: tabs[index],
                  isActive: isActive,
                  onTap: () {
                    // Fast switch without slide animation
                    controller.index = index;
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
