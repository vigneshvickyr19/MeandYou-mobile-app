import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/like_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/like_result.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = FirebaseConstants.users;
  static const String _likesCollection = FirebaseConstants.likes;
  static const String _matchesCollection = FirebaseConstants.matches;

  // Get all users except current user
  Stream<List<UserModel>> getUsers(String currentUserId) {
    return _firestore
        .collection(_usersCollection)
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get users from profileSetup collection
  Stream<List<UserModel>> getUsersNearby(
    String currentUserId, {
    double? maxDistance, // in KM
    double? userLat,
    double? userLng,
  }) {
    return _firestore
        .collection(FirebaseConstants.users) // Use users collection for consistency
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      final List<UserModel> allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      if (maxDistance == null || userLat == null || userLng == null) {
        return allUsers;
      }

      // Filter by distance
      return allUsers.where((user) {
        if (user.latitude == null || user.longitude == null) return false;
        
        final distance = calculateDistance(
          userLat,
          userLng,
          user.latitude!,
          user.longitude!,
        );
        
        return distance <= maxDistance;
      }).toList();
    });
  }

  // Like a user
  Future<LikeResult> likeUser(String fromUserId, String toUserId) async {
    try {
      final likeId = '${fromUserId}_$toUserId';
      
      // Check if already liked in DB
      final existingLike = await _firestore
          .collection(_likesCollection)
          .doc(likeId)
          .get();
      
      if (existingLike.exists) {
        return LikeResult.alreadyLiked;
      }

      // Save like
      final like = LikeModel(
        id: likeId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_likesCollection)
          .doc(likeId)
          .set(like.toMap());

      // Check for mutual like
      final reverseLikeId = '${toUserId}_$fromUserId';
      final reverseLike = await _firestore
          .collection(_likesCollection)
          .doc(reverseLikeId)
          .get();

      if (reverseLike.exists) {
        // It's a match!
        await _createMatch(fromUserId, toUserId);
        return LikeResult.mutualMatch;
      }

      return LikeResult.newLike;
    } catch (e) {
      debugPrint('Error in likeUser: $e');
      return LikeResult.error;
    }
  }

  // Create a match
  Future<void> _createMatch(String userId1, String userId2) async {
    final participants = [userId1, userId2]..sort();
    final matchId = participants.join('_');

    await _firestore.collection(_matchesCollection).doc(matchId).set({
      'participants': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'userId1': userId1,
      'userId2': userId2,
    });

    // Update both likes to mark as mutual
    await _firestore
        .collection(_likesCollection)
        .doc('${userId1}_$userId2')
        .update({'isMutual': true});
    
    await _firestore
        .collection(_likesCollection)
        .doc('${userId2}_$userId1')
        .update({'isMutual': true});
  }

  // Check if users have matched
  Future<bool> checkIfMatched(String userId1, String userId2) async {
    final participants = [userId1, userId2]..sort();
    final matchId = participants.join('_');

    final match = await _firestore
        .collection(_matchesCollection)
        .doc(matchId)
        .get();

    return match.exists;
  }

  // Get people who liked the current user (for the Liked list)
  Stream<List<LikeModel>> getLikesReceived(String userId) {
    return _firestore
        .collection(_likesCollection)
        .where('toUserId', isEqualTo: userId)
        .where('isMutual', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LikeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Remove a like (e.g. after interaction)
  Future<void> removeLike(String fromUserId, String toUserId) async {
    final likeId = '${fromUserId}_$toUserId';
    await _firestore.collection(_likesCollection).doc(likeId).delete();
  }

  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
