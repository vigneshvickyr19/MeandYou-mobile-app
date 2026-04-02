import '../constants/notification_constants.dart';
import '../constants/app_routes.dart';
import 'user_model.dart';

class NotificationPayloadModel {
  final String? type;
  final String? route;
  final String? link;
  final String? chatId;
  final String? profileId;
  final String? title;
  final String? body;
  final Map<String, dynamic> originalData;

  NotificationPayloadModel({
    this.type,
    this.route,
    this.link,
    this.chatId,
    this.profileId,
    this.title,
    this.body,
    required this.originalData,
  });

  factory NotificationPayloadModel.fromMap(Map<String, dynamic> data) {
    // Normalize keys (handle standard and custom keys)
    final type = data[NotificationConstants.keyType]?.toString();
    final route = data[NotificationConstants.keyRoute]?.toString();
    final link = data[NotificationConstants.keyLink]?.toString();
    
    // Normalize ID retrieval with cast safety
    String? chatId = data[NotificationConstants.keyChatId]?.toString();
    if (chatId == null && data[NotificationConstants.keyRoomId] != null) {
      chatId = data[NotificationConstants.keyRoomId]?.toString();
    }
    
    String? profileId = data[NotificationConstants.keyProfileId]?.toString();
    if (profileId == null && data[NotificationConstants.keyUserId] != null) {
       profileId = data[NotificationConstants.keyUserId]?.toString();
    }
    if (profileId == null && data[NotificationConstants.keySenderId] != null) {
       profileId = data[NotificationConstants.keySenderId]?.toString();
    }

    final title = data[NotificationConstants.keyTitle]?.toString();
    final body = data[NotificationConstants.keyBody]?.toString();

    return NotificationPayloadModel(
      type: type,
      route: route,
      link: link,
      chatId: chatId,
      profileId: profileId,
      title: title,
      body: body,
      originalData: data,
    );
  }

  /// Determines the app route based on payload data
  String get targetRoute {
    // 1. Infer from IDs first (highest confidence for specific screens)
    if (chatId != null && chatId!.isNotEmpty) {
      return AppRoutes.chatDetail;
    }
    
    if (profileId != null && profileId!.isNotEmpty) {
      return AppRoutes.otherProfile;
    }

    // 2. Explicit route in payload (standardized or raw)
    if (route != null && route!.isNotEmpty) {
      // Map legacy/string identifiers to actual route constants
      if (route == 'chat_screen' || route == '/chat-detail') return AppRoutes.chatDetail;
      if (route == 'profile_screen' || route == '/other_profile') return AppRoutes.otherProfile;
      if (route == 'home_screen') return AppRoutes.home;
      
      return route!;
    }
    
    // 3. Infer from type
    final normalizedType = type?.toUpperCase();
    if (normalizedType == NotificationConstants.typeChat || normalizedType == 'MESSAGE') {
      if (chatId != null || link != null) return AppRoutes.chatDetail;
      return AppRoutes.chat; // Fallback to chat tab
    }
    
    if (normalizedType == NotificationConstants.typeProfile || 
        normalizedType == 'LIKE' || 
        normalizedType == 'INTEREST' ||
        normalizedType == 'MATCH') {
       return AppRoutes.otherProfile;
    }

    // 3. Fallback to Home
    if (normalizedType == 'SYSTEM' || normalizedType == 'NOTIFICATION') return AppRoutes.home;
    
    return AppRoutes.home;
  }
  
  /// Determines arguments for the route
  Object? get targetArguments {
    final route = targetRoute;

    if (route == AppRoutes.chatDetail) {
      return {
        'chatRoomId': chatId ?? originalData[NotificationConstants.keyRoomId] ?? originalData['id'],
        'otherUser': UserModel(
          id: originalData[NotificationConstants.keySenderId] ?? 
              originalData[NotificationConstants.keyUserId] ?? 
              originalData['sender_id'] ?? '',
          email: '', 
          fullName: originalData[NotificationConstants.keyTitle] ?? 
                    originalData['sender_name'] ?? 'User',
          profileImageUrl: originalData[NotificationConstants.keySenderPhotoUrl] ?? 
                           originalData['sender_image'],
        ),
      };
    }
     
    if (route == AppRoutes.otherProfile) {
      return {
        'userId': profileId ?? originalData[NotificationConstants.keyUserId] ?? originalData['id']
      };
    }
    
    if (route == AppRoutes.home) {
      final tabIndex = int.tryParse(originalData['tabIndex']?.toString() ?? 
                                   originalData['tab_index']?.toString() ?? '0') ?? 0;
      return {'tabIndex': tabIndex};
    }
     
    return originalData;
  }
}
