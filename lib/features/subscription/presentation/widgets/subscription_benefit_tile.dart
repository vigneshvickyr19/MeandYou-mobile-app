import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/benefit_entity.dart';

class SubscriptionBenefitTile extends StatelessWidget {
  final BenefitEntity benefit;

  const SubscriptionBenefitTile({
    super.key,
    required this.benefit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getBenefitIcon(benefit.code), color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                if (benefit.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    benefit.description,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBenefitIcon(String code) {
    switch (code.toUpperCase()) {
      case 'UNLIMITED_LIKES':
        return Icons.favorite_rounded;
      case 'SEE_WHO_LIKES_YOU':
        return Icons.visibility_rounded;
      case 'SET_MORE_PREFERENCES':
        return Icons.tune_rounded;
      case 'DAILY_STANDOUTS':
        return Icons.star_rounded;
      case 'SEE_RECENT_LIKES':
        return Icons.history_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
}
