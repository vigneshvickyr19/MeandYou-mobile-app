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
import '../../../matching/domain/usecases/get_discover_matches_usecase.dart';
import '../../../matching/domain/usecases/get_current_user_profile_usecase.dart';
import '../../../matching/data/repositories/matching_repository_impl.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/admin_service.dart';
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

  final GetDiscoverMatchesUseCase _getDiscoverMatchesUseCase =
      GetDiscoverMatchesUseCase(MatchingRepositoryImpl());
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
  double _radius = 10.0;
  StreamSubscription? _settingsSubscription;
  
  List<NearbyMatchEntity> get matches => _matches;
  bool get isLoading => _isLoading;
  NearbyMatchEntity? get matchedUser => _matchedUser;
  bool get showMatchDialog => _showMatchDialog;

  /// Load users (one-time fetch)
  Future<void> loadUsers(UserModel currentUser, {bool isRefresh = false}) async {
    if (!isRefresh && 
        _lastUserId == currentUser.id && 
        _lastGeohash == currentUser.geohash && 
        _matches.isNotEmpty) {
      return;
    }
    
    _lastUserId = currentUser.id;
    _lastGeohash = currentUser.geohash;

    // Listen to radius changes dynamically
    _settingsSubscription?.cancel();
    _settingsSubscription = AdminService.instance.streamSettings().listen((settings) {
      if (settings.nearbyRadiusInKm != _radius) {
        _radius = settings.nearbyRadiusInKm;
        loadUsers(currentUser);
      }
    });

    if (_matches.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fullProfile = await _getCurrentUserProfileUseCase(currentUser);

      if (fullProfile.latitude == null || fullProfile.longitude == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final adminSettings = await AdminService.instance.getSettings();
      final radius = adminSettings.nearbyRadiusInKm;

      // Exclude already matched users
      final matchedIds = await _homeService.getMatchedUserIds(currentUser.id);

      final matches = await _getDiscoverMatchesUseCase(
        currentUser: fullProfile,
        radiusInKm: radius,
        excludedIds: matchedIds,
      );

      _matches = matches;
      _isLoading = false;
      notifyListeners();

      for (int i = 0; i < math.min(3, matches.length); i++) {
        fetchLocationForMatch(matches[i]);
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
    _settingsSubscription?.cancel();
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
