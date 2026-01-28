import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppVerifiedInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isVerified;

  const AppVerifiedInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkOverlay),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: AppColors.white, fontSize: 15),
                ),
              ),

              if (isVerified) ...[
                const SizedBox(width: 8),
                Row(
                  children: const [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
