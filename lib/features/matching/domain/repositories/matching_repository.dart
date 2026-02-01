import '../entities/nearby_match_entity.dart';
import '../../../../core/models/user_model.dart';

abstract class MatchingRepository {
  /// Stream of nearby users within the given radius
  Stream<List<NearbyMatchEntity>> getNearbyMatches({
    required UserModel currentUser,
    double radiusInKm = 5.0,
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
