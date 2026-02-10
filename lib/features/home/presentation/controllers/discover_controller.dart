import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/notification_api_service.dart';
import '../../../../core/services/notification_payload_builder.dart';
import '../../../notifications/data/services/notification_storage_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../chat/data/models/message_model.dart';
import '../../../matching/domain/entities/nearby_match_entity.dart';
import '../../../matching/domain/usecases/get_nearby_matches_usecase.dart';
import '../../../matching/domain/usecases/get_current_user_profile_usecase.dart';
import '../../../matching/data/repositories/matching_repository_impl.dart';
import '../../../../core/services/location_service.dart';
import '../../data/services/home_service.dart';
import '../../data/models/like_result.dart';

class DiscoverController extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationApiService _notificationApiService =
      NotificationApiService.instance;
  final NotificationStorageService _notificationStorageService =
      NotificationStorageService();

  final GetNearbyMatchesUseCase _getNearbyMatchesUseCase =
      GetNearbyMatchesUseCase(MatchingRepositoryImpl());
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase =
      GetCurrentUserProfileUseCase();

  List<NearbyMatchEntity> _matches = [];
  bool _isLoading = false;
  NearbyMatchEntity? _matchedUser;
  bool _showMatchDialog = false;
  String? _lastUserId;
  String? _lastGeohash;
  
  // Cache to prevent duplicate operations in a single session
  final Set<String> _likedUserIds = {};
  // Track in-flight requests to avoid rapid-fire processing
  final Set<String> _processingIds = {};
  bool _isDisposed = false;
  
  List<NearbyMatchEntity> get matches => _matches;
  bool get isLoading => _isLoading;
  NearbyMatchEntity? get matchedUser => _matchedUser;
  bool get showMatchDialog => _showMatchDialog;

  /// Load users (one-time fetch)
  /// This method is called whenever the AuthProvider emits a new user state
  Future<void> loadUsers(UserModel currentUser) async {
    // If essential search parameters (user ID or geohash/location) haven't changed, 
    // and we already have results, avoid re-fetching to prevent UI flicker.
    if (_lastUserId == currentUser.id && 
        _lastGeohash == currentUser.geohash && 
        _matches.isNotEmpty) {
      return;
    }
    
    _lastUserId = currentUser.id;
    _lastGeohash = currentUser.geohash;

    // Only show loading indicator for the first load or major location shift
    if (_matches.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // 1. Get full profile with location from profileSetup (required for complex matching)
      final fullProfile = await _getCurrentUserProfileUseCase(currentUser);

      if (fullProfile.latitude == null || fullProfile.longitude == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Fetch matches (Now Future-based)
      final matches = await _getNearbyMatchesUseCase(
        currentUser: fullProfile,
        radiusInKm: 10.0,
      );

      // 3. Process and update state
      // Sort matches by match percentage in descending order
      _matches = List.from(matches)..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      _isLoading = false;
      notifyListeners();
      
      // Pre-fetch locations for top matches to ensure text is ready when swiped
      for (int i = 0; i < math.min(3, _matches.length); i++) {
        fetchLocationForMatch(_matches[i]);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('[DiscoverTab] Error loading users: $e');
    }
  }

  Future<void> likeUser(String currentUserId, NearbyMatchEntity match) async {
    // 1. Prevent multiple in-flight requests for the same user
    if (_processingIds.contains(match.id)) return;
    
    // 2. Optimization: If we already liked them in this session, don't ping Firebase
    // But we still allow the UI to "finish" if needed (though card usually moves)
    if (_likedUserIds.contains(match.id)) {
      debugPrint('[Discover] User ${match.id} already liked in this session.');
      return;
    }

    _processingIds.add(match.id);

    try {
      final result = await _homeService.likeUser(currentUserId, match.id);

      if (result == LikeResult.mutualMatch) {
        _likedUserIds.add(match.id);
        _matchedUser = match;
        _showMatchDialog = true;
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUserId: match.id,
          targetUserName: match.fullName,
          interactionType: 'match',
        );
      } else if (result == LikeResult.newLike) {
        _likedUserIds.add(match.id);
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUserId: match.id,
          targetUserName: match.fullName,
          interactionType: 'like',
        );
      } else if (result == LikeResult.alreadyLiked) {
        _likedUserIds.add(match.id);
        debugPrint('[Discover] User was already liked in DB.');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error liking user: $e');
    } finally {
      _processingIds.remove(match.id);
    }
  }

  Future<void> dislikeUser(NearbyMatchEntity match) async {
    // Local optimistic update: immediately hide the card
    _matches.removeWhere((m) => m.id == match.id);
    notifyListeners();
  }

  Future<void> fetchLocationForMatch(NearbyMatchEntity match) async {
    if ((match.area != null && match.area!.isNotEmpty) ||
        (match.landmark != null && match.landmark!.isNotEmpty)) {
      return;
    }

    try {
      final locationData = await LocationService.getReadableLocation(
        match.latitude,
        match.longitude,
      );

      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _matches[index] = _matches[index].copyWith(
          landmark: locationData['landmark'],
          area: locationData['area'],
          fullAddress: locationData['fullAddress'],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching location for match: $e');
    }
  }

  void closeMatchDialog() {
    _showMatchDialog = false;
    _matchedUser = null;
    notifyListeners();
  }

  Future<String> sayHello(String currentUserId, NearbyMatchEntity match) async {
    final chatRoomId = await _chatRepository.getOrCreateChatRoom(currentUserId, match.id);
    final message = MessageModel(
      id: '',
      chatRoomId: chatRoomId,
      senderId: currentUserId,
      receiverId: match.id,
      content: 'Hello 👋',
      timestamp: DateTime.now(),
    );
    await _chatRepository.sendMessage(message);
    return chatRoomId;
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _sendProfileNotification({
    required String currentUserId,
    required String targetUserId,
    required String targetUserName,
    required String interactionType,
  }) async {
    try {
      final targetUser = await _databaseService.getUserById(targetUserId);
      if (targetUser == null || targetUser.fcmToken == null || targetUser.fcmToken!.isEmpty) return;

      final currentUser = await _databaseService.getUserById(currentUserId);
      if (currentUser == null) return;

      final senderName = currentUser.fullName ?? 'Someone';
      final payload = NotificationPayloadBuilder.buildProfileNotification(
        profileId: currentUserId,
        senderId: currentUserId,
        senderName: senderName,
        interactionType: interactionType,
      );

      final titleBody = NotificationPayloadBuilder.extractTitleAndBody(payload);

      await _notificationApiService.sendNotification(
        deviceToken: targetUser.fcmToken!,
        title: titleBody['title']!,
        body: titleBody['body']!,
        data: payload,
      );

      await _notificationStorageService.sendNotification(
        receiverId: targetUserId,
        senderId: currentUserId,
        senderName: senderName,
        senderPhotoUrl: currentUser.profileImageUrl,
        type: interactionType == 'match' ? NotificationType.match : NotificationType.like,
        title: titleBody['title']!,
        message: titleBody['body']!,
        metadata: payload,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
