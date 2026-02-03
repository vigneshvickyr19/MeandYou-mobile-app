import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../data/models/match_model.dart';
import '../../data/services/links_service.dart';

class MatchItem {
  final MatchModel match;
  final UserModel otherUser;

  MatchItem({required this.match, required this.otherUser});
}

class LikeController extends ChangeNotifier {
  final LinksService _linksService = LinksService();
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();

  List<MatchItem> _matches = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  StreamSubscription? _matchesSubscription;
  final Map<String, StreamSubscription> _userSubscriptions = {};
  final Map<String, UserModel> _userCache = {};

  List<MatchItem> get matches => _matches;
  bool get isLoading => _isLoading;

  void init(String currentUserId) {
    if (_isDisposed) return;
    
    _isLoading = true;
    notifyListeners();

    _matchesSubscription?.cancel();
    _matchesSubscription = _linksService.getMatches(currentUserId).listen((matchModels) {
      if (_isDisposed) return;

      // Handle real-time user updates for each match
      for (var match in matchModels) {
        final otherUserId = match.getOtherUserId(currentUserId);
        
        if (otherUserId.isNotEmpty && !_userSubscriptions.containsKey(otherUserId)) {
          // Listen to this user in real-time
          final sub = _databaseService.streamUserById(otherUserId).listen((user) {
            if (user != null) {
              _userCache[otherUserId] = user;
              _rebuildMatches(matchModels, currentUserId);
            }
          });
          _userSubscriptions[otherUserId] = sub;
          
          // Initial fetch to fill cache immediately
          _databaseService.getUserById(otherUserId).then((user) {
            if (user != null && !_isDisposed) {
              _userCache[otherUserId] = user;
              _rebuildMatches(matchModels, currentUserId);
            }
          });
        }
      }
      
      _rebuildMatches(matchModels, currentUserId);
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error loading matches: $error');
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _rebuildMatches(List<MatchModel> matchModels, String currentUserId) {
    if (_isDisposed) return;

    final List<MatchItem> items = [];
    for (var match in matchModels) {
      final otherUserId = match.getOtherUserId(currentUserId);
      final user = _userCache[otherUserId];
      if (user != null) {
        items.add(MatchItem(match: match, otherUser: user));
      }
    }
    
    _matches = items;
    notifyListeners();
  }

  Future<String> getOrCreateChat(String currentUserId, String otherUserId) async {
    try {
      return await _chatRepository.getOrCreateChatRoom(currentUserId, otherUserId);
    } catch (e) {
      debugPrint('Error getting chat room: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _matchesSubscription?.cancel();
    for (var sub in _userSubscriptions.values) {
      sub.cancel();
    }
    _userSubscriptions.clear();
    super.dispose();
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
