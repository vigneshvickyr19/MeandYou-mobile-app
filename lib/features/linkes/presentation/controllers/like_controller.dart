import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../home/data/models/like_model.dart';
import '../../../home/data/services/home_service.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../chat/data/models/message_model.dart';

class LikeController extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final DatabaseService _databaseService = DatabaseService();
  final ChatRepository _chatRepository = ChatRepository();

  List<Map<String, dynamic>> _likedItems = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get likedItems => _likedItems;
  bool get isLoading => _isLoading;

  void loadLikesReceived(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    _homeService.getLikesReceived(currentUserId).listen((likes) async {
      final List<Map<String, dynamic>> items = [];
      
      for (LikeModel like in likes) {
        final user = await _databaseService.getUserById(like.fromUserId);
        if (user != null) {
          items.add({
            'like': like,
            'user': user,
          });
        }
      }
      
      _likedItems = items;
      _isLoading = false;
      notifyListeners();
    });
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

      // Remove the like after interaction
      await _homeService.removeLike(user.id, currentUserId);
      
      return chatRoomId;
    } catch (e) {
      debugPrint('Error in LikeController.sayHello: $e');
      rethrow;
    }
  }

  Future<void> viewProfile(String currentUserId, String fromUserId) async {
    // Remove the like after interaction (as per requirement: "Remove that card from Likes list")
    await _homeService.removeLike(fromUserId, currentUserId);
  }

  String formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inHours < 1) {
      if (difference.inMinutes < 1) return 'Just now';
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
