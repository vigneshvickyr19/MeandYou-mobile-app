import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/nearby_match_entity.dart';
import '../../../../core/models/user_model.dart';

class NearbyResult {
  final List<NearbyMatchEntity> matches;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  NearbyResult({
    required this.matches,
    this.lastDoc,
    this.hasMore = false,
  });
}

abstract class MatchingRepository {
  /// List of nearby users within the given radius with pagination support
  Future<NearbyResult> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
    int limit = 20,
    DocumentSnapshot? lastDoc,
    bool activeOnly = true,
    List<String> excludedIds = const [],
  });

  /// List of discover matches based on user preferences and distance
  Future<List<NearbyMatchEntity>> getDiscoverMatches({
    required UserModel currentUser,
    double radiusInKm = 10.0,
    List<String> excludedIds = const [],
  });

  /// Updates the user's location in Firestore
  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String geohash,
    String? readableAddress,
  });
}
