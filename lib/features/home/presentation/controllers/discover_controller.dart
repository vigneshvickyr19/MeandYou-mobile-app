import 'package:flutter/foundation.dart';
import '../../data/services/home_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/notification_api_service.dart';
import '../../../../core/services/notification_payload_builder.dart';
import '../../../notifications/data/services/notification_storage_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../chat/data/models/message_model.dart';

class DiscoverController extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationApiService _notificationApiService = NotificationApiService.instance;
  final NotificationStorageService _notificationStorageService = NotificationStorageService();

  List<UserModel> _users = [];
  final List<UserModel> _likedUsers = [];
  bool _isLoading = false;
  UserModel? _matchedUser;
  bool _showMatchDialog = false;

  List<UserModel> get users => _users;
  List<UserModel> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  UserModel? get matchedUser => _matchedUser;
  bool get showMatchDialog => _showMatchDialog;

  void loadUsers(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    _homeService.getUsers(currentUserId).listen((users) {
      _users = users;
      _isLoading = false;
      
      // Background sync for users with missing names
      for (var user in users) {
        if (user.fullName == null || user.fullName!.isEmpty) {
          _databaseService.getUserById(user.id);
        }
      }
      
      notifyListeners();
    });
  }

  Future<void> likeUser(String currentUserId, UserModel user) async {
    try {
      final isMatch = await _homeService.likeUser(currentUserId, user.id);
      
      // Remove user from list
      _users.removeWhere((u) => u.id == user.id);
      _likedUsers.add(user);
      
      if (isMatch) {
        _matchedUser = user;
        _showMatchDialog = true;
        
        // Send match notification
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUser: user,
          interactionType: 'match',
        );
      } else {
        // Send like notification
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUser: user,
          interactionType: 'like',
        );
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error liking user: $e');
      }
    }
  }

  Future<void> dislikeUser(UserModel user) async {
    // Just remove from list (no Firebase storage for dislikes)
    _users.removeWhere((u) => u.id == user.id);
    notifyListeners();
  }

  void closeMatchDialog() {
    _showMatchDialog = false;
    _matchedUser = null;
    notifyListeners();
  }

  Future<String> sayHello(String currentUserId, UserModel user) async {
    try {
      // Get or create chat room
      final chatRoomId = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        user.id,
      );

      // Send "Hello 👋" message
      final message = MessageModel(
        id: '',
        chatRoomId: chatRoomId,
        senderId: currentUserId,
        receiverId: user.id,
        content: 'Hello 👋',
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(message);

      return chatRoomId;
    } catch (e) {      rethrow;
    }
  }

  double getDistance(UserModel user) {
    // TODO: Calculate real distance based on user location
    // For now, return random distance for UI
    return (20 + (user.id.hashCode % 80)).toDouble();
  }

  /// Send profile interaction notification using payload builder
  Future<void> _sendProfileNotification({
    required String currentUserId,
    required UserModel targetUser,
    required String interactionType,
  }) async {
    try {
      // Check if target user has FCM token
      if (targetUser.fcmToken == null || targetUser.fcmToken!.isEmpty) {        return;
      }

      // Get current user details
      final currentUser = await _databaseService.getUserById(currentUserId);
      if (currentUser == null) {        return;
      }

      final senderName = currentUser.fullName ?? 'Someone';

      // Build notification payload using the builder
      final payload = NotificationPayloadBuilder.buildProfileNotification(
        profileId: currentUserId,
        senderId: currentUserId,
        senderName: senderName,
        interactionType: interactionType,
      );

      // Validate payload
      if (!NotificationPayloadBuilder.validatePayload(payload)) {        return;
      }

      // Extract title and body
      final titleBody = NotificationPayloadBuilder.extractTitleAndBody(payload);

      // Send notification
      await _notificationApiService.sendNotification(
        deviceToken: targetUser.fcmToken!,
        title: titleBody['title']!,
        body: titleBody['body']!,
        data: payload,
      );

      // Store notification in Firestore for history
      await _notificationStorageService.sendNotification(
        receiverId: targetUser.id,
        senderId: currentUserId,
        senderName: senderName,
        senderPhotoUrl: currentUser.profileImageUrl,
        type: interactionType == 'match' 
            ? NotificationType.match 
            : NotificationType.like,
        title: titleBody['title']!,
        message: titleBody['body']!,
        metadata: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending profile notification: $e');
      }
    }
  }
}
