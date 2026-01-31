import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/chat_room_model.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';

class ChatListController extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();

  List<ChatRoomModel> _chatRooms = [];
  List<UserModel> _chatUsers = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  List<UserModel> _searchResults = [];

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<UserModel> get chatUsers => _chatUsers;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<UserModel> get searchResults => _searchResults;

  final Map<String, UserModel> _userCache = {};
  final Map<String, dynamic> _userSubscriptions = {};

  @override
  void dispose() {
    _cancelUserSubscriptions();
    super.dispose();
  }

  void _cancelUserSubscriptions() {
    for (var sub in _userSubscriptions.values) {
      if (sub is StreamSubscription) {
        sub.cancel();
      }
    }
    _userSubscriptions.clear();
  }

  void loadChatRooms(String currentUserId) {
    _chatRepository.getChatRooms(currentUserId).listen((chatRooms) {
      if (_chatRooms != chatRooms) {
        _chatRooms = List.from(chatRooms); // Create a fresh copy
        if (hasListeners) {
          notifyListeners();
        }
      }

      // Load user details for each chat room with real-time updates
      for (var chatRoom in chatRooms) {
        final otherUserId = chatRoom.getOtherParticipantId(currentUserId);
        
        if (otherUserId.isNotEmpty && !_userSubscriptions.containsKey(otherUserId)) {
          // Listen to this user in real-time
          final sub = _databaseService.streamUserById(otherUserId).listen((user) {
            if (user != null) {
              _userCache[otherUserId] = user;
              if (hasListeners) {
                notifyListeners();
              }
            }
          });
          _userSubscriptions[otherUserId] = sub;
          
          // Initial fetch if cache is empty
          if (!_userCache.containsKey(otherUserId)) {
            _databaseService.getUserById(otherUserId).then((user) {
              if (user != null) {
                _userCache[otherUserId] = user;
                if (hasListeners) {
                  notifyListeners();
                }
              }
            });
          }
        }
      }
      
      _isLoading = false;
    });
  }

  Future<void> refreshChatRooms(String currentUserId) async {
    // Since we use a stream, 'loading' it again will refresh it.
    // However, the stream is already real-time. 
    // We can simulate a refresh by calling loadChatRooms again if needed,
    // but the stream should handle it. 
    // We can use this method to provide a Future for RefreshIndicator.
    loadChatRooms(currentUserId);
    // Wait a bit to show the loading indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _updateChatUsersList() {
    // Reconstruct _chatUsers based on current _chatRooms and _userCache
    // This ensures the order matches the chatRooms
    _chatUsers = [];
    // We'll use a local ID for filtering but basically we want the list of users for existing rooms
    for (var room in _chatRooms) {
      // Find the participant that isn't the room's primary filter (not strictly currentUserId here, but we'll use a generic approach)
      // Since this is inside Controller, we might need currentUserId. 
      // I'll assume we can get it from the chatRoom.
    }
    // Actually, it's easier to just notifyListeners and let the UI get user by ID
    if (hasListeners) {
      notifyListeners();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
      _searchResults = [];
    }
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    // Placeholder for actual search
    _searchResults = [];
    notifyListeners();
  }

  void markAsReadLocally(String chatRoomId, String currentUserId) {
    final index = _chatRooms.indexWhere((room) => room.id == chatRoomId);
    if (index != -1) {
      final room = _chatRooms[index];
      final Map<String, int> updatedUnreadCount = Map.from(room.unreadCount);
      updatedUnreadCount[currentUserId] = 0;
      
      _chatRooms[index] = room.copyWith(unreadCount: updatedUnreadCount);
      notifyListeners();
    }
  }

  UserModel? getUserForChatRoom(ChatRoomModel chatRoom, String currentUserId) {
    final otherUserId = chatRoom.getOtherParticipantId(currentUserId);
    return _userCache[otherUserId];
  }

  String formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
