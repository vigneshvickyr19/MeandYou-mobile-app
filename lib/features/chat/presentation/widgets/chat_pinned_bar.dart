import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Pinned message bar widget
class ChatPinnedBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const ChatPinnedBar({
    super.key,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.push_pin_rounded,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                "Pinned: Tap to view",
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white, size: 18),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
