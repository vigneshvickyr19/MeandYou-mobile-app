import '../repositories/matching_repository.dart';

class UpdateLocationUseCase {
  final MatchingRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<void> call({
    required String userId,
    required double latitude,
    required double longitude,
    required String geohash,
    String? readableAddress,
  }) {
    return repository.updateLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      geohash: geohash,
      readableAddress: readableAddress,
    );
  }
}
