import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/models/user_model.dart';
import 'package:me_and_you/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:me_and_you/features/notifications/data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<NotificationController>().listenToNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Consumer<NotificationController>(
            builder: (context, controller, child) {
              if (controller.notifications.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final userId = context.read<AuthProvider>().currentUser?.id;
                  if (userId != null) {
                    controller.markAllAsRead(userId);
                  }
                },
                child: Text(
                  'Mark all as read',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: AppColors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return _buildNotificationsList(controller.notifications);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.white.withValues(alpha: 0.05),
        indent: 80,
      ),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.withValues(alpha: 0.1),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          onDismissed: (_) {
            context.read<NotificationController>().deleteNotification(notification.id);
          },
          child: _buildNotificationItem(notification),
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.favorite_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.match:
        icon = Icons.favorite;
        iconColor = const Color(0xFFFF4081);
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble_rounded;
        iconColor = const Color(0xFF4A90E2);
        break;
    }

    return InkWell(
      onTap: () async {
        // Handle navigation based on notification type
        if (notification.type == NotificationType.message) {
          final chatId = notification.metadata?['chatId'];
          
          if (chatId != null) {
            // Navigate to chat detail
            await Navigator.pushNamed(
              context,
              AppRoutes.chatDetail,
              arguments: {
                'chatRoomId': chatId,
                'otherUser': UserModel(
                  id: notification.senderId,
                  email: '', // Placeholder as we don't store email in notification
                  fullName: notification.senderName,
                  profileImageUrl: notification.senderPhotoUrl,
                ),
              },
            );
          } else {
            // Fallback to chat list
            Navigator.pushNamed(context, AppRoutes.chat);
          }
        } else if (notification.type == NotificationType.like || 
                   notification.type == NotificationType.match) {
          // Navigate to likes page
          Navigator.pushNamed(context, AppRoutes.likes);
        }

        // Mark as read after interaction (if not already read)
        if (!notification.isRead) {
          context.read<NotificationController>().markAsRead(notification.id);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar or Icon
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    image: notification.senderPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(notification.senderPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: notification.senderPhotoUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          color: AppColors.white.withValues(alpha: 0.2),
                          size: 30,
                        )
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: notification.isRead 
                          ? FontWeight.w400 
                          : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

