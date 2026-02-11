import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Reply preview widget shown inside message bubbles
class MessageReplyPreview extends StatelessWidget {
  final String? senderName;
  final String? content;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const MessageReplyPreview({
    super.key,
    this.senderName,
    this.content,
    required this.isCurrentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (content == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isCurrentUser ? Colors.white : AppColors.primary,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.reply_rounded,
                  size: 12,
                  color: (isCurrentUser ? Colors.white : AppColors.primary)
                      .withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  senderName ?? 'Message',
                  style: TextStyle(
                    color: (isCurrentUser ? Colors.white : AppColors.primary)
                        .withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              content!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
