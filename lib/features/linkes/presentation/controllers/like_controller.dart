import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../home/data/models/like_model.dart';
import '../../../home/data/services/home_service.dart';
import '../../data/models/match_model.dart';
import '../../data/services/links_service.dart';
import '../../../../core/services/like_action_service.dart';

class MatchItem {
  final MatchModel match;
  final UserModel otherUser;

  MatchItem({required this.match, required this.otherUser});
}

class LikeItem {
  final LikeModel like;
  final UserModel fromUser;

  LikeItem({required this.like, required this.fromUser});
}

class LikeController extends ChangeNotifier {
  final LinksService _linksService = LinksService();
  final HomeService _homeService = HomeService();
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();

  List<MatchItem> _matches = [];
  List<LikeItem> _receivedLikes = [];
  
  List<MatchModel> _rawMatches = [];
  List<LikeModel> _rawLikes = [];
  
  bool _likesLoading = false;
  bool _matchesLoading = false;
  bool _isDisposed = false;
  String? _currentUserId;
  
  StreamSubscription? _matchesSubscription;
  StreamSubscription? _likesSubscription;
  
  final Map<String, StreamSubscription> _userSubscriptions = {};
  final Map<String, UserModel> _userCache = {};

  List<MatchItem> get matches => _matches;
  List<LikeItem> get receivedLikes => _receivedLikes;
  bool get isLoading => _likesLoading || _matchesLoading;

  void init(String currentUserId, {bool force = false}) {
    if (_isDisposed) return;
    if (!force && _currentUserId == currentUserId && (_matchesSubscription != null || _likesSubscription != null)) return;
    
    _currentUserId = currentUserId;
    _likesLoading = true;
    _matchesLoading = true;
    
    // Clear stale data
    if (force || _currentUserId != currentUserId) {
      _rawMatches = [];
      _rawLikes = [];
      _matches = [];
      _receivedLikes = [];
      _userCache.clear();
      for (var sub in _userSubscriptions.values) sub.cancel();
      _userSubscriptions.clear();
    }
    
    notifyListeners();

    _matchesSubscription?.cancel();
    _likesSubscription?.cancel();

    _matchesSubscription = _linksService.getMatches(currentUserId).listen((matchModels) {
      if (_isDisposed) return;
      _rawMatches = matchModels;
      _handleUserSubscriptions(matchModels.map((m) => m.getOtherUserId(currentUserId)).toList());
      _rebuildLists();
      _matchesLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error loading matches: $error');
      _matchesLoading = false;
      notifyListeners();
    });

    _likesSubscription = _linksService.getLikesReceived(currentUserId).listen((likeModels) {
      if (_isDisposed) return;
      _rawLikes = likeModels;
      _handleUserSubscriptions(likeModels.map((l) => l.fromUserId).toList());
      _rebuildLists();
      _likesLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error loading likes: $error');
      _likesLoading = false;
      notifyListeners();
    });
  }

  void _handleUserSubscriptions(List<String> userIds) {
    for (var userId in userIds) {
      if (userId.isNotEmpty && !_userSubscriptions.containsKey(userId)) {
        final sub = _databaseService.streamUserById(userId).listen((user) {
          if (user != null && !_isDisposed) {
            _userCache[userId] = user;
            _rebuildLists();
            notifyListeners();
          }
        });
        _userSubscriptions[userId] = sub;
        
        _databaseService.getUserById(userId).then((user) {
          if (user != null && !_isDisposed) {
            _userCache[userId] = user;
            _rebuildLists();
            notifyListeners();
          }
        });
      }
    }
  }

  void _rebuildLists() {
    if (_isDisposed || _currentUserId == null) return;

    final List<MatchItem> matchItems = [];
    for (var match in _rawMatches) {
      final otherUserId = match.getOtherUserId(_currentUserId!);
      final user = _userCache[otherUserId];
      if (user != null) {
        matchItems.add(MatchItem(match: match, otherUser: user));
      }
    }
    _matches = matchItems;

    final List<LikeItem> likeItems = [];
    for (var like in _rawLikes) {
      final user = _userCache[like.fromUserId];
      if (user != null) {
        likeItems.add(LikeItem(like: like, fromUser: user));
      }
    }
    _receivedLikes = likeItems;
  }

  Future<void> likeBack(String currentUserId, String otherUserId) async {
    await LikeActionService.instance.handleLike(otherUserId);
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
    _likesSubscription?.cancel();
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
