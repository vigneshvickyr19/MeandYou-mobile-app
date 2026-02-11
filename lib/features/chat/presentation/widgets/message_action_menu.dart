import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';

/// Bottom sheet action menu for message interactions
class MessageActionMenu extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final Function(String)? onReact;
  final VoidCallback? onReply;
  final VoidCallback? onTogglePin;
  final VoidCallback? onEdit;
  final VoidCallback? onUnsend;
  final VoidCallback? onDeleteForMe;

  const MessageActionMenu({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onReact,
    this.onReply,
    this.onTogglePin,
    this.onEdit,
    this.onUnsend,
    this.onDeleteForMe,
  });

  @override
  Widget build(BuildContext context) {
    final canUnsend = isCurrentUser &&
        DateTime.now().difference(message.timestamp).inMinutes < 2;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildDragHandle(),
            const SizedBox(height: 24),
            _buildReactionRow(context),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Divider(color: Colors.white10, height: 1),
            ),
            _buildActionsList(context, canUnsend),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildReactionRow(BuildContext context) {
    const emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: emojis.map((emoji) {
          final isSelected = message.emojiReactions.values.contains(emoji);
          return _buildReactionButton(context, emoji, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildReactionButton(
    BuildContext context,
    String emoji,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        onReact?.call(emoji);
        Navigator.pop(context);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsList(BuildContext context, bool canUnsend) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 100),
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.reply_rounded,
            title: "Reply",
            onTap: () {
              Navigator.pop(context);
              onReply?.call();
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.push_pin_rounded,
            title: message.isPinned ? "Unpin Message" : "Pin Message",
            onTap: () {
              Navigator.pop(context);
              onTogglePin?.call();
            },
          ),
          if (isCurrentUser) ...[
            if (message.type == MessageType.text)
              _buildMenuItem(
                context: context,
                icon: Icons.edit_rounded,
                title: "Edit Message",
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
            if (canUnsend)
              _buildMenuItem(
                context: context,
                icon: Icons.undo_rounded,
                title: "Unsend Message",
                color: Colors.redAccent.withValues(alpha: 0.9),
                onTap: () {
                  Navigator.pop(context);
                  onUnsend?.call();
                },
              ),
          ],
          _buildMenuItem(
            context: context,
            icon: Icons.delete_outline_rounded,
            title: "Delete for me",
            color: Colors.redAccent.withValues(alpha: 0.8),
            onTap: () {
              Navigator.pop(context);
              onDeleteForMe?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
