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
    final type = data[NotificationConstants.keyType] as String?;
    final route = data[NotificationConstants.keyRoute] as String?;
    final link = data[NotificationConstants.keyLink] as String?;
    
    // Normalize ID retrieval
    String? chatId = data[NotificationConstants.keyChatId] as String?;
    if (chatId == null && data[NotificationConstants.keyRoomId] != null) {
      chatId = data[NotificationConstants.keyRoomId] as String?;
    }
    
    String? profileId = data[NotificationConstants.keyProfileId] as String?;
    if (profileId == null && data[NotificationConstants.keyUserId] != null) {
       // Sometimes userId in payload implies profile to view
       profileId = data[NotificationConstants.keyUserId] as String?;
    }

    final title = data[NotificationConstants.keyTitle] as String?;
    final body = data[NotificationConstants.keyBody] as String?;

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
    // 1. Explicit route in payload
    if (route != null && route!.isNotEmpty) {
      return route!;
    }
    
    // 2. Infer from type
    if (type == NotificationConstants.typeChat) {
      if (chatId != null || link != null) return AppRoutes.chatDetail;
    }
    
    if (type == NotificationConstants.typeProfile) {
       return AppRoutes.otherProfile;
    }

    // 3. Fallback to Home
    return AppRoutes.home;
  }
  
  /// Determines arguments for the route
  Object? get targetArguments {
     if (type == NotificationConstants.typeChat) {
       if (chatId != null) {
         return {
           'chatRoomId': chatId,
           'otherUser': UserModel(
             id: originalData[NotificationConstants.keySenderId] ?? 
                 originalData[NotificationConstants.keyUserId] ?? '',
             email: '', // Not stored in notification payload
             fullName: originalData[NotificationConstants.keyTitle] ?? 'User',
             profileImageUrl: originalData[NotificationConstants.keySenderPhotoUrl],
           ),
         };
       }
     }
     
     if (type == NotificationConstants.typeProfile) {
       if (profileId != null) {
         return {'userId': profileId};
       }
     }
     
     return originalData;
  }
}
