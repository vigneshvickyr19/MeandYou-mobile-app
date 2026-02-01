import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DateSeparator extends StatelessWidget {
  final String label;

  const DateSeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
