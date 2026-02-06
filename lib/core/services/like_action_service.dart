import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../features/home/data/services/home_service.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/notifications/data/services/notification_storage_service.dart';
import 'notification_api_service.dart';
import 'database_service.dart';
import 'admin_service.dart';
import '../../features/home/data/models/like_result.dart';
import '../constants/notification_constants.dart';
import '../constants/firebase_constants.dart';
import '../models/admin_settings_model.dart';

import 'package:intl/intl.dart';

class LikeLimitReachedException implements Exception {
  final String message;
  LikeLimitReachedException(this.message);
  @override
  String toString() => message;
}

class LikeActionService {
  static final LikeActionService _instance = LikeActionService._();
  static LikeActionService get instance => _instance;

  LikeActionService._();

  final HomeService _homeService = HomeService();
  final NotificationStorageService _notificationStorage = NotificationStorageService();
  final DatabaseService _databaseService = DatabaseService();

  /// Core reusable like functionality
  /// 1. Saves like in DB
  /// 2. Sends push notification
  /// 3. Stores in-app notification
  Future<void> handleLike(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('LikeActionService: No authenticated user');
      return;
    }

    final String currentUserId = currentUser.uid;

    try {
      // 0. Check Daily Limit
      final userAccount = await _databaseService.getUserById(currentUserId);
      final adminSettings = await AdminService.instance.getSettings();
      
      final gender = userAccount?.gender?.toLowerCase() ?? 'male';
      
      // Determine max likes (Check user override first, then gender default)
      int maxLikes = adminSettings.userOverrides[currentUserId] ?? 
                    (gender == 'female' ? adminSettings.femaleFreeLikes : adminSettings.maleFreeLikes);
      
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dailyLikesRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.users)
          .doc(currentUserId)
          .collection(FirebaseConstants.dailyStats)
          .doc(FirebaseConstants.likes);

      final dailyDoc = await dailyLikesRef.get();
      int currentCount = 0;
      
      if (dailyDoc.exists) {
        final data = dailyDoc.data()!;
        if (data['lastUpdated'] == today) {
          currentCount = data['count'] ?? 0;
        }
      }

      if (currentCount >= maxLikes) {
        throw LikeLimitReachedException("You've reached your daily free like limit.");
      }

      // 1. Perform Like in Database
      final result = await _homeService.likeUser(currentUserId, targetUserId);
      
      // Update Daily Count only if it was a "newLike" or "mutualMatch"
      if (result != LikeResult.error && result != LikeResult.alreadyLiked) {
        await dailyLikesRef.set({
          'count': currentCount + 1,
          'lastUpdated': today,
        }, SetOptions(merge: true));

        // Fetch current user details for notification (already fetched userAccount above)
        final senderName = userAccount?.fullName ?? 'Someone';
        final senderPhotoUrl = userAccount?.profileImageUrl;

        // Fetch target user to get FCM token
        final targetUser = await _databaseService.getUserById(targetUserId);
        
        // 2. Create and Store In-App Notification
        await _notificationStorage.sendNotification(
          receiverId: targetUserId,
          senderId: currentUserId,
          senderName: senderName,
          senderPhotoUrl: senderPhotoUrl,
          type: NotificationType.like,
          title: 'New Like!',
          message: '$senderName liked your profile',
          metadata: {
            'type': 'like',
            'senderId': currentUserId,
          },
        );

        // 3. Send Push Notification if token exists
        if (targetUser?.fcmToken != null) {
          await NotificationApiService.instance.sendNotification(
            deviceToken: targetUser!.fcmToken!,
            title: 'New Like!',
            body: '$senderName liked your profile',
            data: {
              NotificationConstants.keyType: NotificationConstants.typeProfile,
              NotificationConstants.keySenderId: currentUserId,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          );
        }
      }

      debugPrint('LikeActionService: Successfully processed like for $targetUserId');
    } catch (e) {
      debugPrint('LikeActionService: Error handling like: $e');
      rethrow;
    }
  }
}
