import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../../domain/entities/nearby_match_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<NearbyMatchEntity>> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
  }) {
    // 1. Calculate Geohash Range
    final String userGeohash = currentUser.geohash ?? '';

    if (userGeohash.isEmpty) {
      return Stream.value([]);
    }

    // We'll use a safer approach for the prefix
    final String precisionPrefix = userGeohash.length >= 4
        ? userGeohash.substring(0, 4)
        : userGeohash;
    return _firestore
        .collection(FirebaseConstants.profileSetup)
        .where('geohash', isGreaterThanOrEqualTo: precisionPrefix)
        .where('geohash', isLessThanOrEqualTo: '$precisionPrefix\uf8ff')
        .snapshots()
        .map((snapshot) {
          final List<NearbyMatchEntity> matches = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final String userId = doc.id;
            final String userName =
                data[FirebaseConstants.fullName] ?? 'Unknown';

            // Exclude self
            if (userId == currentUser.id) {
              continue;
            }

            // Exclude blocked or swiped users
            if (currentUser.blockedUsers.contains(userId)) {
              continue;
            }
            if (currentUser.swipedUsers.contains(userId)) {
              continue;
            }

            final double lat =
                (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
            final double lng =
                (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;

            // Calculate distance
            final double distance = _calculateDistance(
              currentUser.latitude ?? 0,
              currentUser.longitude ?? 0,
              lat,
              lng,
            );

            // Filter by radius
            if (distance > radiusInKm) {
              continue;
            }

            // Calculate match percentage
            final double matchPercentage = _calculateMatchPercentage(
              currentUser,
              data,
              distance,
              radiusInKm,
            );

            matches.add(
              NearbyMatchEntity(
                id: userId,
                fullName: userName,
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
                interests: List<String>.from(
                  data[FirebaseConstants.interests] ?? [],
                ),
              ),
            );
          }

          // Sort by match percentage
          matches.sort(
            (a, b) => b.matchPercentage.compareTo(a.matchPercentage),
          );
          return matches;
        });
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

    await _firestore
        .collection(FirebaseConstants.profileSetup)
        .doc(userId)
        .update(updateData);
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
