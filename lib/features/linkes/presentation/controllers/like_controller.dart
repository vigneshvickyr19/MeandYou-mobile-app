import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
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

  List<MatchItem> _matches = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  StreamSubscription? _matchesSubscription;

  List<MatchItem> get matches => _matches;
  bool get isLoading => _isLoading;

  void init(String currentUserId) {
    if (_isDisposed) return;
    
    _isLoading = true;
    notifyListeners();

    _matchesSubscription?.cancel();
    _matchesSubscription = _linksService.getMatches(currentUserId).listen((matchModels) async {
      if (_isDisposed) return;

      try {
        final List<Future<MatchItem?>> futures = matchModels.map((match) async {
          final otherUserId = match.getOtherUserId(currentUserId);
          final otherUser = await _linksService.getUserById(otherUserId);
          if (otherUser != null) {
            return MatchItem(match: match, otherUser: otherUser);
          }
          return null;
        }).toList();

        final items = (await Future.wait(futures))
            .whereType<MatchItem>()
            .toList();
        
        if (!_isDisposed) {
          _matches = items;
          _isLoading = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error processing matches: $e');
        if (!_isDisposed) {
          _isLoading = false;
          notifyListeners();
        }
      }
    }, onError: (error) {
      debugPrint('Error loading matches: $error');
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    });
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
