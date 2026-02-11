import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Reaction pill widget displaying emoji reactions and like count
class MessageReactionPill extends StatelessWidget {
  final Map<String, String> emojiReactions;
  final int likeCount;
  final VoidCallback? onTap;

  const MessageReactionPill({
    super.key,
    required this.emojiReactions,
    required this.likeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (emojiReactions.isEmpty && likeCount == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: -6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emojiReactions.isNotEmpty) ..._buildEmojiStack(),
            if (likeCount > 0) ..._buildLikeSection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmojiStack() {
    final uniqueEmojis = emojiReactions.values.toSet().take(3).toList();
    
    return [
      Stack(
        clipBehavior: Clip.none,
        children: [
          ...uniqueEmojis.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(left: entry.key * 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2D2D2D),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
        ],
      ),
      if (emojiReactions.length > 1)
        Padding(
          padding: EdgeInsets.only(
            left: (uniqueEmojis.length - 1) * 12.0 + 18.0,
          ),
          child: Text(
            emojiReactions.length.toString(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      else
        const SizedBox(width: 4),
    ];
  }

  List<Widget> _buildLikeSection() {
    return [
      if (emojiReactions.isNotEmpty) const SizedBox(width: 8),
      const Icon(
        Icons.favorite,
        size: 13,
        color: Colors.red,
      ),
      const SizedBox(width: 3),
      Text(
        likeCount.toString(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }
}
