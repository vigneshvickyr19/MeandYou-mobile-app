import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DistanceBadge extends StatelessWidget {
  final double distance;
  final bool showIcon;

  const DistanceBadge({
    super.key,
    required this.distance,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.location_on,
              color: AppColors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '${distance.toInt()}km',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
