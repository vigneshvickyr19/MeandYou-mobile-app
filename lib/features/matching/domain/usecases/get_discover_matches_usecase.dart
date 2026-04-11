import '../entities/nearby_match_entity.dart';
import '../repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';

class GetDiscoverMatchesUseCase {
  final MatchingRepository repository;

  GetDiscoverMatchesUseCase(this.repository);

  Future<List<NearbyMatchEntity>> call({
    required UserModel currentUser,
    double radiusInKm = 10.0,
    List<String> excludedIds = const [],
  }) {
    return repository.getDiscoverMatches(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
      excludedIds: excludedIds,
    );
  }
}
