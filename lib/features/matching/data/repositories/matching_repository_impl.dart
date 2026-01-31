import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'dart:math' as math;
import '../models/nearby_match_model.dart';
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
    
    // DEBUG: Log current user info
    print('🔍 ===== NEARBY MATCHES DEBUG =====');
    print('📍 Current User: ${currentUser.fullName} (${currentUser.id})');
    print('📍 Current Location: lat=${currentUser.latitude}, lng=${currentUser.longitude}');
    print('📍 Current Geohash: $userGeohash');
    print('📍 Search Radius: ${radiusInKm}km');
    print('📍 Current User Interests: ${currentUser.interests}');
    print('📍 Current User Gender: ${currentUser.gender}');
    print('📍 Current User Preferences: ${currentUser.preferences}');
    
    if (userGeohash.isEmpty) {
      print('❌ ERROR: Current user has no geohash! Cannot search nearby users.');
      return Stream.value([]);
    }

    // We'll use a safer approach for the prefix
    final String precisionPrefix = userGeohash.length >= 4 
        ? userGeohash.substring(0, 4) 
        : userGeohash;
    
    print('🔎 Geohash Prefix for Query: $precisionPrefix');

    return _firestore
        .collection(FirebaseConstants.profileSetup)
        .where('geohash', isGreaterThanOrEqualTo: precisionPrefix)
        .where('geohash', isLessThanOrEqualTo: '$precisionPrefix\uf8ff')
        .snapshots()
        .map((snapshot) {
      print('\n📦 Firestore Query Results: ${snapshot.docs.length} documents found');
      
      final List<NearbyMatchEntity> matches = [];
      int excludedSelf = 0;
      int excludedBlocked = 0;
      int excludedSwiped = 0;
      int excludedDistance = 0;
      int includedUsers = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String userId = doc.id;
        final String userName = data[FirebaseConstants.fullName] ?? 'Unknown';

        // Exclude self
        if (userId == currentUser.id) {
          excludedSelf++;
          print('⏭️  Skipped: $userName (self)');
          continue;
        }

        // Exclude blocked or swiped users
        if (currentUser.blockedUsers.contains(userId)) {
          excludedBlocked++;
          print('🚫 Skipped: $userName (blocked)');
          continue;
        }
        if (currentUser.swipedUsers.contains(userId)) {
          excludedSwiped++;
          print('👉 Skipped: $userName (already swiped)');
          continue;
        }

        final double lat = (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
        final double lng = (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;
        final String otherGeohash = data[FirebaseConstants.geohash] ?? '';

        print('\n👤 Checking User: $userName');
        print('   Location: lat=$lat, lng=$lng');
        print('   Geohash: $otherGeohash');

        // Calculate distance
        final double distance = _calculateDistance(
          currentUser.latitude ?? 0,
          currentUser.longitude ?? 0,
          lat,
          lng,
        );

        print('   📏 Distance: ${distance.toStringAsFixed(2)}km');

        // Filter by radius
        if (distance > radiusInKm) {
          excludedDistance++;
          print('   ❌ EXCLUDED: Distance ${distance.toStringAsFixed(2)}km > ${radiusInKm}km radius');
          continue;
        }

        // Calculate match percentage
        final double matchPercentage = _calculateMatchPercentage(
          currentUser,
          data,
          distance,
          radiusInKm,
        );

        print('   ✅ INCLUDED: Distance ${distance.toStringAsFixed(2)}km within radius');
        print('   💯 Match Percentage: ${matchPercentage.toStringAsFixed(1)}%');

        matches.add(NearbyMatchEntity(
          id: userId,
          fullName: userName,
          profileImageUrl: data[FirebaseConstants.profileImageUrl],
          distance: distance,
          matchPercentage: matchPercentage,
          address: data[FirebaseConstants.address],
          age: data[FirebaseConstants.age] ?? 18,
          latitude: lat,
          longitude: lng,
          interests: List<String>.from(data[FirebaseConstants.interests] ?? []),
        ));
        includedUsers++;
      }

      // Sort by match percentage
      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      
      print('\n📊 ===== SUMMARY =====');
      print('✅ Total Included: $includedUsers users');
      print('⏭️  Excluded (Self): $excludedSelf');
      print('🚫 Excluded (Blocked): $excludedBlocked');
      print('👉 Excluded (Swiped): $excludedSwiped');
      print('📏 Excluded (Distance): $excludedDistance');
      print('🎯 Final Matches: ${matches.length}');
      
      if (matches.isNotEmpty) {
        print('\n🏆 Top Matches:');
        for (var i = 0; i < math.min(3, matches.length); i++) {
          final match = matches[i];
          print('   ${i + 1}. ${match.fullName} - ${match.matchPercentage.toStringAsFixed(1)}% (${match.distance.toStringAsFixed(2)}km)');
        }
      } else {
        print('\n⚠️  NO MATCHES FOUND!');
        print('💡 Possible reasons:');
        print('   - No users in profileSetup collection');
        print('   - All users are beyond ${radiusInKm}km radius');
        print('   - All users are blocked or already swiped');
        print('   - Current user location not set properly');
      }
      print('================================\n');
      
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

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
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
    final String otherName = otherData[FirebaseConstants.fullName] ?? 'Unknown';
    double score = 0;
    
    print('   💯 Calculating Match % for $otherName:');

    // 1. Interests (40%)
    final otherInterests = List<String>.from(otherData[FirebaseConstants.interests] ?? []);
    double interestScore = 0;
    if (currentUser.interests.isNotEmpty) {
      final common = currentUser.interests.where((i) => otherInterests.contains(i)).length;
      interestScore = (common / currentUser.interests.length) * 40;
      score += interestScore;
      print('      🎯 Interests: $common common / ${currentUser.interests.length} total = ${interestScore.toStringAsFixed(1)}% (max 40%)');
      print('         My interests: ${currentUser.interests}');
      print('         Their interests: $otherInterests');
    } else {
      print('      🎯 Interests: 0% (current user has no interests set)');
    }

    // 2. Preferences (30%)
    final otherGender = otherData[FirebaseConstants.gender];
    final myLookingFor = currentUser.preferences?['lookingFor'];
    double genderScore = 0;
    if (myLookingFor == otherGender) {
      genderScore = 30;
      score += 30;
      print('      ⚧️  Gender Match: ✅ ${genderScore.toStringAsFixed(1)}% (looking for: $myLookingFor, they are: $otherGender)');
    } else {
      print('      ⚧️  Gender Match: ❌ 0% (looking for: $myLookingFor, they are: $otherGender)');
    }

    // 3. Age Range (20%)
    final otherAge = otherData[FirebaseConstants.age] ?? 18;
    final minAge = currentUser.preferences?['minAge'] ?? 18;
    final maxAge = currentUser.preferences?['maxAge'] ?? 99;
    double ageScore = 0;
    if (otherAge >= minAge && otherAge <= maxAge) {
      ageScore = 20;
      score += 20;
      print('      🎂 Age Match: ✅ ${ageScore.toStringAsFixed(1)}% (age: $otherAge, range: $minAge-$maxAge)');
    } else {
      print('      🎂 Age Match: ❌ 0% (age: $otherAge, range: $minAge-$maxAge)');
    }

    // 4. Distance (10%)
    final distanceScore = (1 - (distance / radiusInKm)) * 10;
    final finalDistanceScore = math.max(0, distanceScore);
    score += finalDistanceScore;
    print('      📏 Distance: ${finalDistanceScore.toStringAsFixed(1)}% (${distance.toStringAsFixed(2)}km / ${radiusInKm}km radius)');

    final finalScore = math.min(100, math.max(1, score)).toDouble();
    print('      ✨ TOTAL MATCH: ${finalScore.toStringAsFixed(1)}%');
    
    return finalScore;
  }
}
