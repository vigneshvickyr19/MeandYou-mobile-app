import '../entities/nearby_match_entity.dart';
import '../repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';

class GetNearbyMatchesUseCase {
  final MatchingRepository repository;

  GetNearbyMatchesUseCase(this.repository);

  Future<List<NearbyMatchEntity>> call({
    required UserModel currentUser,
    double radiusInKm = 5.0,
  }) {
    return repository.getNearbyMatches(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
    );
  }
}
