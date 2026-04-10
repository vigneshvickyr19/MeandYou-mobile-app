import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'dart:math' as math;
import '../../domain/entities/nearby_match_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<NearbyResult> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
    int limit = 20,
    DocumentSnapshot? lastDoc,
    bool activeOnly = true,
  }) async {
    final List<NearbyMatchEntity> allMatches = [];
    DocumentSnapshot? newLastDoc;

    // 1. Fetch matching profiles based on geohash
    // Note: For true scalability with startAfter in Firestore across multiple geohashes, 
    // we query a slightly larger batch and filter.
    final List<Map<String, dynamic>> rawProfiles = await _fetchProfilesByLocationPaginated(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
      limit: limit,
      lastDoc: lastDoc,
    );

    // 2. Filter and Map
    final DateTime activeThreshold = DateTime.now().subtract(const Duration(hours: 24));

    for (var data in rawProfiles) {
      final String id = data['id'];
      
      // Filter: Current User
      if (id == currentUser.id) continue;

      // Filter: Activity (24h)
      if (activeOnly) {
        final lastUpdate = (data[FirebaseConstants.lastLocationUpdate] as Timestamp?)?.toDate();
        if (lastUpdate == null || lastUpdate.isBefore(activeThreshold)) {
          continue;
        }
      }

      final double lat = (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
      final double lng = (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;
      
      final double distance = _calculateDistance(
        currentUser.latitude ?? 0,
        currentUser.longitude ?? 0,
        lat,
        lng,
      );

      // Filter: Exact Radius (Haversine)
      if (distance > radiusInKm) continue;

      allMatches.add(_mapToEntity(data, distance, 0));
    }

    // 3. Handle last document for next page
    // We capture the original snapshot from the data source if possible
    newLastDoc = rawProfiles.isNotEmpty ? rawProfiles.last['_snapshot'] as DocumentSnapshot? : null;

    return NearbyResult(
      matches: allMatches,
      lastDoc: newLastDoc,
      hasMore: rawProfiles.length >= limit,
    );
  }

  @override
  Future<List<NearbyMatchEntity>> getDiscoverMatches({
    required UserModel currentUser,
    double radiusInKm = 10.0,
  }) async {
    // 0. Fetch Current User Profile from profileSetup (Single source of truth)
    final profileSnapshot = await _firestore
        .collection(FirebaseConstants.profileSetup)
        .doc(currentUser.id)
        .get();
    
    final Map<String, dynamic> myProfileData = profileSnapshot.data() ?? {};
    final String? myLookingFor = myProfileData['lookingFor'];
    final int myMinAge = myProfileData['minAge'] ?? 18;
    final int myMaxAge = myProfileData['maxAge'] ?? 99;

    final List<Map<String, dynamic>> rawProfiles = await _fetchProfilesByLocationPaginated(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
      limit: 50,
    );

    final List<NearbyMatchEntity> matches = [];

    for (var data in rawProfiles) {
      final double lat = (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0;
      final double lng = (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0;

      final double distance = _calculateDistance(
        currentUser.latitude ?? 0,
        currentUser.longitude ?? 0,
        lat,
        lng,
      );

      if (distance > radiusInKm) continue;

      // DISCOVER CRITERIA: lookingFor, minAge, maxAge, distance
      
      // 1. Calculate Age Compatibility
      int otherAge = _calculateAge(data['dob']);
      
      // If NOT compatible at all (e.g., outside age range), you might want to skip 
      // or just give lower percentage. User said only these parameters.
      // I'll calculate percentage based on these.

      final double matchPercentage = _calculateDiscoverMatchPercentage(
        myLookingFor: myLookingFor,
        otherLookingFor: data['lookingFor'],
        otherAge: otherAge,
        myMinAge: myMinAge,
        myMaxAge: myMaxAge,
        distance: distance,
        radiusInKm: radiusInKm,
      );

      matches.add(_mapToEntity(data, distance, matchPercentage));
    }

    // Sort: Match Percentage (Primary), Distance (Secondary)
    matches.sort((a, b) {
      int cmp = b.matchPercentage.compareTo(a.matchPercentage);
      if (cmp == 0) return a.distance.compareTo(b.distance);
      return cmp;
    });

    return matches;
  }

  /// Paginated helper to fetch profiles using geohash range queries
  Future<List<Map<String, dynamic>>> _fetchProfilesByLocationPaginated({
    required UserModel currentUser,
    required double radiusInKm,
    required int limit,
    DocumentSnapshot? lastDoc,
  }) async {
    final String userGeohash = currentUser.geohash ?? '';
    if (userGeohash.isEmpty) return [];

    // 1. Calculate geohash precision based on radius
    // 4 chars is roughly 20km x 20km, 5 chars is ~5km x 5km
    int precision = radiusInKm <= 5 ? 5 : 4;
    final String centerHash = userGeohash.length >= precision 
        ? userGeohash.substring(0, precision) 
        : userGeohash;

    final GeoHasher hasher = GeoHasher();
    final Map<String, String> neighbors = hasher.neighbors(centerHash);
    final List<String> allCells = [centerHash, ...neighbors.values];

    final List<Future<QuerySnapshot<Map<String, dynamic>>>> queryFutures = [];
    
    for (final cell in allCells) {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirebaseConstants.profileSetup)
          .orderBy(FirebaseConstants.geohash)
          .startAt([cell])
          .endAt(['$cell\uf8ff']);
      
      // If we have a cursor, we skip cells that are "before" the cursor geohash 
      // or start after it in the current cell.
      if (lastDoc != null) {
        final lastGeohash = lastDoc.get(FirebaseConstants.geohash) as String;
        // Optimization: Only query cells that could contain geohashes >= lastGeohash
        if (cell.compareTo(lastGeohash.substring(0, cell.length)) >= 0) {
           query = query.startAfterDocument(lastDoc);
        } else {
           continue; // Skip this cell entirely as it's lexically before our cursor's cell
        }
      }

      queryFutures.add(query.limit(limit).get());
    }

    final List<QuerySnapshot<Map<String, dynamic>>> snapshots =
        await Future.wait(queryFutures);

    final List<Map<String, dynamic>> rawResults = [];
    final Set<String> seenIds = {};

    for (var snapshot in snapshots) {
      for (var doc in snapshot.docs) {
        if (doc.id == currentUser.id) continue;
        if (seenIds.contains(doc.id)) continue;
        
        rawResults.add({
          ...doc.data(), 
          'id': doc.id,
          '_snapshot': doc // Attach snapshot for cursor tracking
        });
        seenIds.add(doc.id);
      }
    }

    // Sort by geohash to ensure consistent pagination across all merged results
    rawResults.sort((a, b) => (a[FirebaseConstants.geohash] as String)
        .compareTo(b[FirebaseConstants.geohash] as String));

    // Trim to limit
    if (rawResults.length > limit) {
      return rawResults.sublist(0, limit);
    }

    return rawResults;
  }

  int _calculateAge(dynamic dobData) {
    if (dobData == null) return 18;
    final DateTime? dob = (dobData is Timestamp) ? dobData.toDate() : null;
    if (dob == null) return 18;
    
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  NearbyMatchEntity _mapToEntity(Map<String, dynamic> data, double distance, double matchPercentage) {
    String? profilePic;
    if (data['photos'] != null && (data['photos'] as List).isNotEmpty) {
      profilePic = (data['photos'] as List).first;
    }

    return NearbyMatchEntity(
      id: data['id'],
      fullName: data[FirebaseConstants.fullName] ?? 'Unknown',
      profileImageUrl: profilePic,
      distance: distance,
      matchPercentage: matchPercentage,
      address: data[FirebaseConstants.address],
      landmark: data['landmark'],
      area: data['area'],
      fullAddress: data[FirebaseConstants.address],
      age: _calculateAge(data['dob']),
      latitude: (data[FirebaseConstants.latitude] as num?)?.toDouble() ?? 0,
      longitude: (data[FirebaseConstants.longitude] as num?)?.toDouble() ?? 0,
      interests: List<String>.from(data[FirebaseConstants.interests] ?? []),
    );
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

  double _calculateDiscoverMatchPercentage({
    required String? myLookingFor,
    required String? otherLookingFor,
    required int otherAge,
    required int myMinAge,
    required int myMaxAge,
    required double distance,
    required double radiusInKm,
  }) {
    double score = 0;

    // 1. Looking For (30%) - Intent alignment
    if (myLookingFor != null && otherLookingFor != null) {
      if (myLookingFor == otherLookingFor) {
        score += 30;
      } else if ((myLookingFor == 'Marriage' && otherLookingFor == 'Relationship') ||
                 (myLookingFor == 'Relationship' && otherLookingFor == 'Marriage')) {
        score += 20; // High compatibility but not exact
      }
    }

    // 2. Age Range (40%)
    if (otherAge >= myMinAge && otherAge <= myMaxAge) {
      score += 40;
    } else {
      // Partial credit for being very close to the range
      int diff = 0;
      if (otherAge < myMinAge) diff = (myMinAge - otherAge).abs();
      if (otherAge > myMaxAge) diff = (otherAge - myMaxAge).abs();
      
      if (diff <= 2) {
        score += 20; // 2 years out
      } else if (diff <= 5) {
        score += 10; // 5 years out
      }
    }

    // 3. Distance (30%)
    // Linear decay based on search radius
    double distanceFactor = 1 - (distance / radiusInKm);
    score += math.max(0, distanceFactor * 30);

    return math.min(100, math.max(1, score)).toDouble();
  }
}
