import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'dart:math' as math;
import '../../domain/entities/nearby_match_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<NearbyMatchEntity>> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
  }) async {
    // 0. Fetch Current User Profile from profileSetup (Single source of truth for matching)
    final profileSnapshot = await _firestore
        .collection(FirebaseConstants.profileSetup)
        .doc(currentUser.id)
        .get();
    
    final Map<String, dynamic> profileData = profileSnapshot.data() ?? {};
    
    // Extract preferences directly from profile document
    final String? myLookingFor = profileData['lookingFor'];
    final int myMinAge = profileData['minAge'] ?? 18;
    final int myMaxAge = profileData['maxAge'] ?? 99;
    final List<String> myInterests = List<String>.from(profileData['interests'] ?? []);

    final String userGeohash = currentUser.geohash ?? '';
    if (userGeohash.isEmpty) return [];

    // 1. Calculate geohash precision
    // Length 4 covers ~39km x 39km. Better for a 10km radius search.
    // Length 5 covers only ~4.9km, which might miss users 10km away even with neighbors.
    final String centerHash = userGeohash.length >= 4 
        ? userGeohash.substring(0, 4) 
        : userGeohash;

    // 2. Get neighbor hashes (9 cells including center)
    final GeoHasher hasher = GeoHasher();
    final Map<String, String> neighbors = hasher.neighbors(centerHash);
    final List<String> allCells = [centerHash, ...neighbors.values];

    // 3. Execute parallel queries for each cell
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> queryFutures = [];
    for (final cell in allCells) {
      queryFutures.add(
        _firestore
            .collection(FirebaseConstants.profileSetup)
            .orderBy(FirebaseConstants.geohash)
            .startAt([cell])
            .endAt(['$cell\uf8ff'])
            .limit(50) // Increased limit for broader cells
            .get(),
      );
    }

    // 4. Merge results and filter
    final List<QuerySnapshot<Map<String, dynamic>>> snapshots =
        await Future.wait(queryFutures);

    final Map<String, NearbyMatchEntity> uniqueMatches = {};

    for (var snapshot in snapshots) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String userId = doc.id;

        // 5. Filters: Self, Blocked, Swiped
        if (userId == currentUser.id) continue;
        
        // Skip users that current user has already interacted with (blocked/swiped)
        // Note: These fields should be added to UserModel or fetched from a separate collection
        // For now, we continue with local deduplication
        if (uniqueMatches.containsKey(userId)) continue;

        final double lat =
            (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
        final double lng =
            (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;

        // 6. Exact distance filtering
        final double distance = _calculateDistance(
          currentUser.latitude ?? 0,
          currentUser.longitude ?? 0,
          lat,
          lng,
        );

        if (distance > radiusInKm) continue;

        // 5. Extract Profile Image (from photos list)
        String? profilePic;
        if (data['photos'] != null && (data['photos'] as List).isNotEmpty) {
          profilePic = (data['photos'] as List).first;
        }

        // 6. Calculate Age from DOB
        int userAge = 18;
        if (data['dob'] != null) {
          final DateTime? dob = (data['dob'] as Timestamp?)?.toDate();
          if (dob != null) {
            final now = DateTime.now();
            userAge = now.year - dob.year;
            if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
              userAge--;
            }
          }
        }

        final double matchPercentage = _calculateMatchPercentage(
          myLookingFor: myLookingFor,
          myMinAge: myMinAge,
          myMaxAge: myMaxAge,
          myInterests: myInterests,
          otherData: data,
          distance: distance,
          radiusInKm: radiusInKm,
        );

        uniqueMatches[userId] = NearbyMatchEntity(
          id: userId,
          fullName: data[FirebaseConstants.fullName] ?? 'Unknown',
          profileImageUrl: profilePic,
          distance: distance,
          matchPercentage: matchPercentage,
          address: data[FirebaseConstants.address],
          landmark: data['landmark'],
          area: data['area'],
          fullAddress: data[FirebaseConstants.address],
          age: userAge,
          latitude: lat,
          longitude: lng,
          interests: List<String>.from(data[FirebaseConstants.interests] ?? []),
        );
      }
    }

    final List<NearbyMatchEntity> results = uniqueMatches.values.toList();
    debugPrint('[MatchingRepository] Found ${results.length} matches in geographic vicinity.');

    // Sort: Match Percentage (Primary), Distance (Secondary)
    results.sort((a, b) {
      int cmp = b.matchPercentage.compareTo(a.matchPercentage);
      if (cmp == 0) return a.distance.compareTo(b.distance);
      return cmp;
    });

    return results;
  }

  @override
  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String geohash,
    String? readableAddress,
  }) async {
    final Map<String, dynamic> updateData = {
      FirebaseConstants.latitude: latitude,
      FirebaseConstants.longitude: longitude,
      FirebaseConstants.geohash: geohash,
      FirebaseConstants.lastLocationUpdate: FieldValue.serverTimestamp(),
    };

    if (readableAddress != null) {
      updateData[FirebaseConstants.address] = readableAddress;
    }

    // Update profileSetup (for matching engine)
    final batch = _firestore.batch();

    final profileRef = _firestore
        .collection(FirebaseConstants.profileSetup)
        .doc(userId);
    final userRef = _firestore.collection(FirebaseConstants.users).doc(userId);

    batch.set(profileRef, updateData, SetOptions(merge: true));

    // Also update users collection (for AuthProvider/UI state)
    batch.set(
      userRef,
      {
        FirebaseConstants.latitude: latitude,
        FirebaseConstants.longitude: longitude,
        FirebaseConstants.geohash: geohash,
        FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  double _calculateMatchPercentage({
    required String? myLookingFor,
    required int myMinAge,
    required int myMaxAge,
    required List<String> myInterests,
    required Map<String, dynamic> otherData,
    required double distance,
    required double radiusInKm,
  }) {
    double score = 0;
    // 1. Interests (40%)
    final otherInterests = List<String>.from(
      otherData[FirebaseConstants.interests] ?? [],
    );
    if (myInterests.isNotEmpty) {
      final common = myInterests
          .where((i) => otherInterests.contains(i))
          .length;
      final interestScore = (common / myInterests.length) * 40;
      score += interestScore;
    }

    // 2. Preferences - lookingFor (30%)
    // Matches relationship intentions (e.g., both looking for 'Relationship' or 'Marriage')
    final otherLookingFor = otherData['lookingFor'];
    if (myLookingFor != null && otherLookingFor != null) {
       if (myLookingFor == otherLookingFor) {
         score += 30;
       } else if (myLookingFor == 'Marriage' && otherLookingFor == 'Relationship') {
         score += 20; // High compatibility
       } else if (myLookingFor == 'Relationship' && otherLookingFor == 'Marriage') {
         score += 20;
       }
    }

    // 3. Age Range (20%)
    int otherAge = 18;
    if (otherData['dob'] != null) {
      final DateTime? dob = (otherData['dob'] as Timestamp?)?.toDate();
      if (dob != null) {
        final now = DateTime.now();
        otherAge = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          otherAge--;
        }
      }
    }

    if (otherAge >= myMinAge && otherAge <= myMaxAge) {
      score += 20;
    }

    // 4. Distance (10%)
    final distanceScore = (1 - (distance / radiusInKm)) * 10;
    score += math.max(0, distanceScore);

    return math.min(100, math.max(1, score)).toDouble();
  }
}
