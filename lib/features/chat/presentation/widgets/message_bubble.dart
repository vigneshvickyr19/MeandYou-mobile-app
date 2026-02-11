import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';
import 'message_image_grid.dart';
import 'voice_message_bubble.dart';
import 'message_reply_preview.dart';
import 'message_reaction_pill.dart';
import 'message_status_indicator.dart';
import 'message_action_menu.dart';

/// Message bubble widget displaying individual chat messages
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isLastInGroup;
  final DateTime? otherUserLastReadAt;
  final VoidCallback? onLike;
  final Function(String)? onReact;
  final VoidCallback? onResend;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onUnsend;
  final VoidCallback? onDeleteForMe;
  final VoidCallback? onTogglePin;
  final VoidCallback? onScrollToReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isLastInGroup = true,
    this.otherUserLastReadAt,
    this.onLike,
    this.onReact,
    this.onResend,
    this.onReply,
    this.onEdit,
    this.onUnsend,
    this.onDeleteForMe,
    this.onTogglePin,
    this.onScrollToReply,
  });

  Color _getBubbleColor() {
    return isCurrentUser ? AppColors.primary : const Color(0xFF262626);
  }

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 300),
      from: 0.95,
      child: FadeInUp(
        duration: const Duration(milliseconds: 200),
        from: 10,
        child: _buildBubbleContent(context),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isCurrentUser ? 48 : 0,
          right: isCurrentUser ? 0 : 48,
          bottom: isLastInGroup ? 10 : 2,
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildMessageBubble(context),
            MessageStatusIndicator(
              message: message,
              isCurrentUser: isCurrentUser,
              isLastInGroup: isLastInGroup,
              otherUserLastReadAt: otherUserLastReadAt,
              onResend: onResend,
            ),
            MessageReactionPill(
              emojiReactions: message.emojiReactions,
              likeCount: message.likeCount,
              onTap: () => _showActionMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showActionMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isCurrentUser ? 18 : (isLastInGroup ? 4 : 18),
            ),
            bottomRight: Radius.circular(
              isCurrentUser ? (isLastInGroup ? 4 : 18) : 18,
            ),
          ),
        ),
        child: Opacity(
          opacity: message.status == MessageStatus.sending ? 0.7 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.replyToMessageId != null)
                MessageReplyPreview(
                  senderName: message.replyToSenderName,
                  content: message.replyToContent,
                  isCurrentUser: isCurrentUser,
                  onTap: onScrollToReply,
                ),
              if (message.type == MessageType.image && !message.isUnsent)
                _buildImageContent(context),
              if (message.type == MessageType.audio &&
                  message.audioUrl != null &&
                  !message.isUnsent)
                VoiceMessageBubble(
                  audioUrl: message.audioUrl!,
                  duration: message.duration ?? '0:00',
                  isCurrentUser: isCurrentUser,
                ),
              if (message.content.isNotEmpty) _buildTextContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: message.imageUrls.isNotEmpty
          ? MessageImageGrid(
              imageUrls: message.imageUrls,
              isLocalPath: !message.imageUrls.first.startsWith('http'),
            )
          : (message.imageUrl != null
              ? MessageImageGrid(
                  imageUrls: [message.imageUrl!],
                  isLocalPath: !message.imageUrl!.startsWith('http'),
                )
              : const SizedBox.shrink()),
    );
  }

  Widget _buildTextContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            message.isUnsent ? 'This message was unsent' : message.content,
            style: TextStyle(
              color: message.isUnsent
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white,
              fontSize: 15,
              height: 1.3,
              fontStyle:
                  message.isUnsent ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        if (message.isEdited && !message.isUnsent)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Edited',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  void _showActionMenu(BuildContext context) {
    if (message.isUnsent) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessageActionMenu(
        message: message,
        isCurrentUser: isCurrentUser,
        onReact: onReact,
        onReply: onReply,
        onTogglePin: onTogglePin,
        onEdit: onEdit,
        onUnsend: onUnsend,
        onDeleteForMe: onDeleteForMe,
      ),
    );
  }
}
