import '../entities/nearby_match_entity.dart';
import '../../../../core/models/user_model.dart';

abstract class MatchingRepository {
  /// List of nearby users within the given radius (Pure location-based)
  Future<List<NearbyMatchEntity>> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
  });

  /// List of discover matches based on user preferences and distance
  Future<List<NearbyMatchEntity>> getDiscoverMatches({
    required UserModel currentUser,
    double radiusInKm = 10.0,
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
