import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/nearby_match_entity.dart';
import '../repositories/matching_repository.dart';
import '../../../../core/models/user_model.dart';

class GetNearbyMatchesUseCase {
  final MatchingRepository repository;

  GetNearbyMatchesUseCase(this.repository);

  @Deprecated('Use executeWithPagination instead')
  Future<List<NearbyMatchEntity>> call({
    required UserModel currentUser,
    double radiusInKm = 5.0,
  }) async {
    final result = await repository.getNearbyMatches(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
    );
    return result.matches;
  }

  Future<NearbyResult> executeWithPagination({
    required UserModel currentUser,
    double radiusInKm = 5.0,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) {
    return repository.getNearbyMatches(
      currentUser: currentUser,
      radiusInKm: radiusInKm,
      limit: limit,
      lastDoc: lastDoc,
    );
  }
}
