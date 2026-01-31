import 'package:flutter/material.dart';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';
import 'message_image_grid.dart';
import 'voice_message_bubble.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isLastInGroup;
  final DateTime? otherUserLastReadAt;
  final VoidCallback? onLike;
  final Function(String)? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isLastInGroup = true,
    this.otherUserLastReadAt,
    this.onLike,
    this.onReact,
  });

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getBubbleColor() {
    if (isCurrentUser) {
      return AppColors.primary;
    }
    return const Color(0xFF262626);
  }

  @override
  Widget build(BuildContext context) {
    final child = Align(
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
            // Message Bubble
            GestureDetector(
              onLongPress: () {
                if (onReact != null) {
                  _showReactionPicker(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.type == MessageType.image)
                      Container(
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
                      ),
                    if (message.type == MessageType.audio && message.audioUrl != null)
                      VoiceMessageBubble(
                        audioUrl: message.audioUrl!,
                        duration: message.duration ?? '0:00',
                        isCurrentUser: isCurrentUser,
                      ),
                    if (message.content.isNotEmpty)
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Time and Status (Only show if last in group or shows significant gap)
            if (isLastInGroup)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Builder(
                        builder: (context) {
                          // A message is seen if the other user has read the chat 
                          // at or after this message's timestamp.
                          bool isSeen = false;
                          if (otherUserLastReadAt != null) {
                            // Using isAtSameMomentAs or isAfter for precision
                            isSeen = otherUserLastReadAt!.isAtSameMomentAs(message.timestamp) || 
                                     otherUserLastReadAt!.isAfter(message.timestamp);
                          }
                          
                          return Icon(
                            isSeen ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 14,
                            color: isSeen
                                ? AppColors.info
                                : Colors.white.withOpacity(0.4),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            
            // Reactions
            if (message.reactions.isNotEmpty || message.likeCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.reactions.isNotEmpty)
                      ...message.reactions.take(3).map(
                            (reaction) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Text(
                                reaction,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                    if (message.likeCount > 0) ...[
                      const Icon(
                        Icons.favorite,
                        size: 12,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        message.likeCount.toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    return ZoomIn(
      duration: const Duration(milliseconds: 300),
      from: 0.95,
      child: FadeInUp(
        duration: const Duration(milliseconds: 200),
        from: 10,
        child: child,
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final reactions = ['❤️', '😂', '😮', '😢', '😡', '👍'];
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'React to message',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: reactions.map((reaction) {
                  return GestureDetector(
                    onTap: () {
                      if (onReact != null) {
                        onReact!(reaction);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      reaction,
                      style: const TextStyle(fontSize: 32),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

