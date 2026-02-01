import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/chat_room_model.dart';
import '../../../../core/models/user_model.dart';
import 'chat_avatar.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoomModel chatRoom;
  final UserModel? user;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chatRoom,
    required this.user,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getLastMessagePreview() {
    if (chatRoom.lastMessage.isEmpty) return 'Tap to chat';
    
    final isMe = chatRoom.lastMessageSenderId == currentUserId;
    final prefix = isMe ? 'You: ' : '';
    
    // Check for media message markers which we now set in Repository
    if (chatRoom.lastMessage == 'Sent an image') {
      return '${prefix}Image';
    } else if (chatRoom.lastMessage == 'Sent a video') {
      return '${prefix}Video';
    }
    
    return '$prefix${chatRoom.lastMessage}';
  }

  Widget _buildLastMessageStatus(int unreadCount, bool isMe, String otherUserId) {
    if (!isMe) {
      if (unreadCount > 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // If I am the sender, show if they've seen the last message
    // A message is "seen" only if the recipient's lastReadAt is at or after the message timestamp
    final otherLastReadAt = chatRoom.getLastReadAt(otherUserId);
    final isSeen = !chatRoom.lastMessageTime.isAfter(otherLastReadAt);
    
    return Icon(
      isSeen ? Icons.done_all_rounded : Icons.done_rounded,
      size: 16,
      color: isSeen ? AppColors.info : AppColors.white.withValues(alpha: 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = chatRoom.getUnreadCount(currentUserId);
    final otherUserId = chatRoom.getOtherParticipantId(currentUserId);
    final isTyping = chatRoom.isUserTyping(otherUserId);
    final isMe = chatRoom.lastMessageSenderId == currentUserId;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar
            ChatAvatar(
              imageUrl: user?.profileImageUrl,
              isOnline: user?.isOnline ?? false,
              size: 56,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user?.fullName ?? 'Unknown User',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chatRoom.lastMessageTime),
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isTyping ? 'Typing...' : _getLastMessagePreview(),
                          style: TextStyle(
                            color: isTyping 
                                ? AppColors.primary 
                                : AppColors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildLastMessageStatus(unreadCount, isMe, otherUserId),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
