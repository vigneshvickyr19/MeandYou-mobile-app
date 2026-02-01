import 'package:flutter/foundation.dart';
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

class DiscoverController extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final ChatRepository _chatRepository = ChatRepository();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationApiService _notificationApiService = NotificationApiService.instance;
  final NotificationStorageService _notificationStorageService = NotificationStorageService();
  
  // Use matching repository for better match data
  final GetNearbyMatchesUseCase _getNearbyMatchesUseCase = GetNearbyMatchesUseCase(
    MatchingRepositoryImpl(),
  );
  
  // Use the same usecase as Nearby tab to fetch full profile with location
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase = GetCurrentUserProfileUseCase();

  List<NearbyMatchEntity> _matches = [];
  final List<NearbyMatchEntity> _likedMatches = [];
  bool _isLoading = false;
  NearbyMatchEntity? _matchedUser;
  bool _showMatchDialog = false;

  List<NearbyMatchEntity> get matches => _matches;
  List<NearbyMatchEntity> get likedMatches => _likedMatches;
  bool get isLoading => _isLoading;
  NearbyMatchEntity? get matchedUser => _matchedUser;
  bool get showMatchDialog => _showMatchDialog;

  /// Load users with match percentage and distance calculation
  Future<void> loadUsers(UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get full profile from profileSetup collection (includes location data)
      // This is the same approach used by Nearby tab
      final fullProfile = await _getCurrentUserProfileUseCase(currentUser);
      
      // Check if user has location data
      if (fullProfile.latitude == null || fullProfile.longitude == null || fullProfile.geohash == null) {
        if (kDebugMode) {
          debugPrint('[DiscoverTab] User location data is missing. Latitude: ${fullProfile.latitude}, Longitude: ${fullProfile.longitude}, Geohash: ${fullProfile.geohash}');
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (kDebugMode) {
        debugPrint('[DiscoverTab] Full profile loaded with location: lat=${fullProfile.latitude}, lng=${fullProfile.longitude}, geohash=${fullProfile.geohash}');
      }

      // Start listening to matches with full profile
      _getNearbyMatchesUseCase(
        currentUser: fullProfile,
        radiusInKm: 10.0, // 10km radius (same as Nearby tab)
      ).listen((matches) async {
        _matches = matches;
        _isLoading = false;
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('[DiscoverTab] Loaded ${matches.length} matches');
        }

        // Proactively fetch location for the first 3 matches
        for (int i = 0; i < math.min(3, _matches.length); i++) {
          await fetchLocationForMatch(_matches[i]);
        }
      }, onError: (error) {
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) {
          debugPrint('[DiscoverTab] Error loading matches: $error');
        }
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('[DiscoverTab] Error in loadUsers: $e');
      }
    }
  }

  Future<void> likeUser(String currentUserId, NearbyMatchEntity match) async {
    try {
      final isMatch = await _homeService.likeUser(currentUserId, match.id);
      
      // Remove match from list
      _matches.removeWhere((m) => m.id == match.id);
      _likedMatches.add(match);
      
      if (isMatch) {
        _matchedUser = match;
        _showMatchDialog = true;
        
        // Send match notification
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUserId: match.id,
          targetUserName: match.fullName,
          interactionType: 'match',
        );
      } else {
        // Send like notification
        await _sendProfileNotification(
          currentUserId: currentUserId,
          targetUserId: match.id,
          targetUserName: match.fullName,
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

  Future<void> dislikeUser(NearbyMatchEntity match) async {
    // Just remove from list (no Firebase storage for dislikes)
    _matches.removeWhere((m) => m.id == match.id);
    notifyListeners();
  }

  /// Fetch readable location name for a match if not already present
  Future<void> fetchLocationForMatch(NearbyMatchEntity match) async {
    // If we already have area/landmark, no need to fetch again
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
      if (kDebugMode) {
        debugPrint('Error fetching location for match in Discover: $e');
      }
    }
  }

  void closeMatchDialog() {
    _showMatchDialog = false;
    _matchedUser = null;
    notifyListeners();
  }

  Future<String> sayHello(String currentUserId, NearbyMatchEntity match) async {
    try {
      // Get or create chat room
      final chatRoomId = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        match.id,
      );

      // Send "Hello 👋" message
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
    } catch (e) {
      rethrow;
    }
  }

  /// Get distance from match (already calculated in matching repository)
  double getDistance(NearbyMatchEntity match) {
    return match.distance;
  }

  /// Send profile interaction notification using payload builder
  Future<void> _sendProfileNotification({
    required String currentUserId,
    required String targetUserId,
    required String targetUserName,
    required String interactionType,
  }) async {
    try {
      // Get target user details for FCM token
      final targetUser = await _databaseService.getUserById(targetUserId);
      if (targetUser == null) {
        return;
      }
      
      // Check if target user has FCM token
      if (targetUser.fcmToken == null || targetUser.fcmToken!.isEmpty) {
        return;
      }

      // Get current user details
      final currentUser = await _databaseService.getUserById(currentUserId);
      if (currentUser == null) {
        return;
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
      if (!NotificationPayloadBuilder.validatePayload(payload)) {
        return;
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
        receiverId: targetUserId,
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
