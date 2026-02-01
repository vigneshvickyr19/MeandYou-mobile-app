import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStatsCard extends StatelessWidget {
  final String label;
  final String value;

  const ProfileStatsCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
