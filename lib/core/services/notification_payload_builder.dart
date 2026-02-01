import '../constants/notification_constants.dart';
import '../constants/app_routes.dart';

/// Builder class for creating notification payloads
/// Ensures consistency and validation across all notification types
class NotificationPayloadBuilder {
  /// Build a chat message notification payload
  static Map<String, dynamic> buildChatNotification({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String messagePreview,
    required String messageType, // 'text', 'image', 'reaction', 'voice', 'video'
    int? imageCount,
  }) {
    // Validate required fields
    if (chatId.isEmpty) {
      throw ArgumentError('chatId cannot be empty');
    }
    if (senderId.isEmpty) {
      throw ArgumentError('senderId cannot be empty');
    }
    if (senderName.isEmpty) {
      throw ArgumentError('senderName cannot be empty');
    }

    // Build description based on message type
    String description;
    switch (messageType.toLowerCase()) {
      case 'text':
        description = messagePreview;
        break;
      case 'image':
        if (imageCount != null && imageCount > 1) {
          description = NotificationConstants.msgDescriptionImages;
        } else {
          description = NotificationConstants.msgDescriptionImage;
        }
        break;
      case 'reaction':
        description = NotificationConstants.msgDescriptionReaction;
        break;
      case 'voice':
      case 'audio':
        description = NotificationConstants.msgDescriptionVoice;
        break;
      case 'video':
        description = NotificationConstants.msgDescriptionVideo;
        break;
      default:
        description = messagePreview;
    }

    return {
      NotificationConstants.keyType: NotificationConstants.typeChat,
      NotificationConstants.keyTitle: senderName,
      NotificationConstants.keyDescription: description,
      NotificationConstants.keyBody: description, // For backward compatibility
      NotificationConstants.keyChatId: chatId,
      NotificationConstants.keyRoomId: chatId, // For backward compatibility
      NotificationConstants.keySenderId: senderId,
      NotificationConstants.keySenderPhotoUrl: senderPhotoUrl,
      NotificationConstants.keyRoute: AppRoutes.chatDetail,
      NotificationConstants.keyScreen: NotificationConstants.screenChat,
    };
  }

  /// Build a profile interaction notification payload
  static Map<String, dynamic> buildProfileNotification({
    required String profileId,
    required String senderId,
    required String senderName,
    required String interactionType, // 'like', 'match', 'view'
  }) {
    // Validate required fields
    if (profileId.isEmpty) {
      throw ArgumentError('profileId cannot be empty');
    }
    if (senderId.isEmpty) {
      throw ArgumentError('senderId cannot be empty');
    }
    if (senderName.isEmpty) {
      throw ArgumentError('senderName cannot be empty');
    }

    // Build description based on interaction type
    String description;
    switch (interactionType.toLowerCase()) {
      case 'like':
        description = NotificationConstants.profileDescriptionLike;
        break;
      case 'match':
        description = NotificationConstants.profileDescriptionMatch;
        break;
      default:
        description = NotificationConstants.profileDescriptionLike;
    }

    return {
      NotificationConstants.keyType: NotificationConstants.typeProfile,
      NotificationConstants.keyTitle: senderName,
      NotificationConstants.keyDescription: description,
      NotificationConstants.keyBody: description, // For backward compatibility
      NotificationConstants.keyProfileId: profileId,
      NotificationConstants.keyUserId: senderId, // The user who performed the action
      NotificationConstants.keySenderId: senderId,
      NotificationConstants.keyRoute: AppRoutes.otherProfile,
      NotificationConstants.keyScreen: NotificationConstants.screenProfile,
    };
  }

  /// Validate a notification payload
  static bool validatePayload(Map<String, dynamic> payload) {
    // Check required keys
    if (!payload.containsKey(NotificationConstants.keyType)) {
      return false;
    }
    if (!payload.containsKey(NotificationConstants.keyTitle)) {
      return false;
    }
    if (!payload.containsKey(NotificationConstants.keyDescription) &&
        !payload.containsKey(NotificationConstants.keyBody)) {
      return false;
    }
    if (!payload.containsKey(NotificationConstants.keyRoute)) {
      return false;
    }

    // Type-specific validation
    final type = payload[NotificationConstants.keyType];
    
    if (type == NotificationConstants.typeChat) {
      if (!payload.containsKey(NotificationConstants.keyChatId) &&
          !payload.containsKey(NotificationConstants.keyRoomId)) {
        return false;
      }
      if (!payload.containsKey(NotificationConstants.keySenderId)) {
        return false;
      }
    }

    if (type == NotificationConstants.typeProfile) {
      if (!payload.containsKey(NotificationConstants.keyProfileId)) {
        return false;
      }
      if (!payload.containsKey(NotificationConstants.keySenderId)) {
        return false;
      }
    }

    return true;
  }

  /// Extract title and body for API call
  static Map<String, String> extractTitleAndBody(Map<String, dynamic> payload) {
    final title = payload[NotificationConstants.keyTitle]?.toString() ?? 'Notification';
    final body = payload[NotificationConstants.keyDescription]?.toString() ??
        payload[NotificationConstants.keyBody]?.toString() ??
        '';

    return {
      'title': title,
      'body': body,
    };
  }
}
