import 'package:flutter/material.dart';
import '../../data/services/home_service.dart';
import '../../data/models/like_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../chat/data/models/message_model.dart';

class DiscoverController extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final ChatRepository _chatRepository = ChatRepository();

  List<UserModel> _users = [];
  List<UserModel> _likedUsers = [];
  bool _isLoading = false;
  UserModel? _matchedUser;
  bool _showMatchDialog = false;

  List<UserModel> get users => _users;
  List<UserModel> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  UserModel? get matchedUser => _matchedUser;
  bool get showMatchDialog => _showMatchDialog;

  final DatabaseService _databaseService = DatabaseService();

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
      }
      
      notifyListeners();
    } catch (e) {
      print('Error liking user: $e');
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
    } catch (e) {
      print('Error sending hello: $e');
      rethrow;
    }
  }

  double getDistance(UserModel user) {
    // TODO: Calculate real distance based on user location
    // For now, return random distance for UI
    return (20 + (user.id.hashCode % 80)).toDouble();
  }
}
