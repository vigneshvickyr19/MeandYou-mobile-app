import 'package:cloud_firestore/cloud_firestore.dart';
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
    final String userGeohash = currentUser.geohash ?? '';
    if (userGeohash.isEmpty) return [];

    // 1. Calculate geohash precision for 5km (Length 5 is ~4.9km)
    // 9 cells of length 5 cover ~15km x 15km area
    final String centerHash = userGeohash.length >= 5 
        ? userGeohash.substring(0, 5) 
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
            .limit(20) // Limit to avoid massive reads
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
        if (currentUser.blockedUsers.contains(userId)) continue;
        if (currentUser.swipedUsers.contains(userId)) continue;
        if (uniqueMatches.containsKey(userId)) continue;

        final double lat = (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
        final double lng = (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;

        // 6. Exact distance filtering
        final double distance = _calculateDistance(
          currentUser.latitude ?? 0,
          currentUser.longitude ?? 0,
          lat,
          lng,
        );

        if (distance > radiusInKm) continue;

        final double matchPercentage = _calculateMatchPercentage(
          currentUser,
          data,
          distance,
          radiusInKm,
        );

        uniqueMatches[userId] = NearbyMatchEntity(
          id: userId,
          fullName: data[FirebaseConstants.fullName] ?? 'Unknown',
          profileImageUrl: data[FirebaseConstants.profileImageUrl],
          distance: distance,
          matchPercentage: matchPercentage,
          address: data[FirebaseConstants.address],
          landmark: data['landmark'],
          area: data['area'],
          fullAddress: data[FirebaseConstants.address],
          age: data[FirebaseConstants.age] ?? 18,
          latitude: lat,
          longitude: lng,
          interests: List<String>.from(data[FirebaseConstants.interests] ?? []),
        );
      }
    }

    final List<NearbyMatchEntity> results = uniqueMatches.values.toList();
    
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
    
    final profileRef = _firestore.collection(FirebaseConstants.profileSetup).doc(userId);
    final userRef = _firestore.collection(FirebaseConstants.users).doc(userId);

    batch.update(profileRef, updateData);
    
    // Also update users collection (for AuthProvider/UI state)
    batch.update(userRef, {
      FirebaseConstants.latitude: latitude,
      FirebaseConstants.longitude: longitude,
      FirebaseConstants.geohash: geohash,
      FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
    });

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

  double _calculateMatchPercentage(
    UserModel currentUser,
    Map<String, dynamic> otherData,
    double distance,
    double radiusInKm,
  ) {
    double score = 0;
    // 1. Interests (40%)
    final otherInterests = List<String>.from(
      otherData[FirebaseConstants.interests] ?? [],
    );
    if (currentUser.interests.isNotEmpty) {
      final common = currentUser.interests
          .where((i) => otherInterests.contains(i))
          .length;
      final interestScore = (common / currentUser.interests.length) * 40;
      score += interestScore;
    }

    // 2. Preferences (30%)
    final otherGender = otherData[FirebaseConstants.gender];
    final myLookingFor = currentUser.preferences?['lookingFor'];
    if (myLookingFor == otherGender) {
      score += 30;
    }

    // 3. Age Range (20%)
    final otherAge = otherData[FirebaseConstants.age] ?? 18;
    final minAge = currentUser.preferences?['minAge'] ?? 18;
    final maxAge = currentUser.preferences?['maxAge'] ?? 99;
    if (otherAge >= minAge && otherAge <= maxAge) {
      score += 20;
    }

    // 4. Distance (10%)
    final distanceScore = (1 - (distance / radiusInKm)) * 10;
    score += math.max(0, distanceScore);

    return math.min(100, math.max(1, score)).toDouble();
  }
}
