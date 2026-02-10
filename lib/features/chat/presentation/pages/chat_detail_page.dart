import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/chat_detail_controller.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_input.dart';
import '../../../../core/widgets/app_image_preview_modal.dart';
import '../../../../core/widgets/app_back_button.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatRoomId;
  final UserModel otherUser;

  const ChatDetailPage({
    super.key,
    required this.chatRoomId,
    required this.otherUser,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late ChatDetailController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatDetailController();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _controller.initialize(
        widget.chatRoomId,
        authProvider.currentUser!.id,
        widget.otherUser.id,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showImagePreview(ChatDetailController controller) {
    if (controller.selectedImages.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImagePreviewModal(
          images: controller.selectedImages,
          onSend: (caption) async {
            await controller.sendMessage(caption);
            _scrollToBottom();
          },
          onClose: () {
            Navigator.of(context).pop();
            controller.clearSelectedImages();
          },
        ),
      ),
    );
  }

  bool _isUserOnline(Map<String, dynamic>? status) {
    if (status == null) return false;
    return status['state'] == 'online';
  }

  String _getPresenceStatus(Map<String, dynamic>? status) {
    if (status == null) return 'Offline';
    if (status['state'] == 'online') return 'Online';

    final lastChanged = status['lastChanged'];
    if (lastChanged == null) return 'Offline';

    final lastChangedDate = DateTime.fromMillisecondsSinceEpoch(lastChanged);
    final now = DateTime.now();
    final difference = now.difference(lastChangedDate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ChatDetailController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AppBar(
                    backgroundColor: AppColors.black.withValues(alpha: 0.7),
                    elevation: 0,
                    leading: const Center(
                      child: AppBackButton(),
                    ),
                    title: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.otherProfile,
                          arguments: {'userId': widget.otherUser.id},
                        );
                      },
                      child: Row(
                        children: [
                          ChatAvatar(
                            imageUrl: widget.otherUser.profileImageUrl,
                            isOnline: _isUserOnline(controller.otherUserStatus),
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.otherUser.fullName ?? 'Unknown',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _getPresenceStatus(controller.otherUserStatus),
                                  style: TextStyle(
                                    color: _isUserOnline(controller.otherUserStatus)
                                        ? const Color(0xFF4CAF50)
                                        : AppColors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.videocam_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          _controller.initiateCall('VIDEO');
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.call_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          _controller.initiateCall('AUDIO');
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Background pattern or color
                      Container(color: AppColors.black),

                      // Chat Content
                      if (controller.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      else if (controller.messages.isEmpty)
                        FadeIn(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 48,
                                    color: AppColors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation with ${widget.otherUser.fullName}',
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kToolbarHeight +
                                8,
                            bottom: 16,
                            left: 12,
                            right: 12,
                          ),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            final isCurrentUser =
                                message.senderId == currentUserId;
                            final showDateLabel = controller
                                .shouldShowDateLabel(index);
                            
                            // Check if next message is from same sender to reduce spacing
                            bool isLastInGroup = true;
                            if (index > 0) {
                              isLastInGroup = controller.messages[index - 1].senderId != message.senderId;
                            }

                            return Column(
                              children: [
                                if (showDateLabel)
                                  DateSeparator(
                                    label: controller.getDateLabel(
                                      message.timestamp,
                                    ),
                                  ),
                                MessageBubble(
                                  message: message,
                                  isCurrentUser: isCurrentUser,
                                  isLastInGroup: isLastInGroup,
                                  otherUserLastReadAt: controller.chatRoom?.getLastReadAt(controller.chatRoom?.getOtherParticipantId(currentUserId) ?? ''),
                                  onLike: () =>
                                      controller.likeMessage(message.id),
                                  onReact: (reaction) => controller.addReaction(
                                    message.id,
                                    reaction,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Bottom Section (Typing + Input)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isOtherUserTyping)
                      FadeInUp(
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.otherUser.fullName} is typing...',
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    MessageInput(
                      onSendMessage: (content) {
                        controller.sendMessage(content);
                        _scrollToBottom();
                      },
                      onImagesSelected: (images) {
                        controller.clearSelectedImages();
                        for (var image in images) {
                          controller.addImage(image);
                        }
                        _showImagePreview(controller);
                      },
                      selectedImages: controller.selectedImages,
                      onClearImages: controller.clearSelectedImages,
                      onTypingChanged: controller.updateTypingStatus,
                      onStartRecording: controller.startRecording,
                      onStopRecording: controller.stopRecording,
                      onCancelRecording: controller.cancelRecording,
                      onSendVoiceMessage: (path, duration) async {
                         await controller.sendVoiceMessage(path, duration);
                         _scrollToBottom();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
