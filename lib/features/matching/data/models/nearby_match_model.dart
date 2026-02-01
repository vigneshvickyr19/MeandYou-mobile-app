import '../../domain/entities/nearby_match_entity.dart';

class NearbyMatchModel extends NearbyMatchEntity {
  const NearbyMatchModel({
    required super.id,
    required super.fullName,
    super.profileImageUrl,
    required super.distance,
    required super.matchPercentage,
    super.address,
    required super.age,
    required super.latitude,
    required super.longitude,
    required super.interests,
  });

  factory NearbyMatchModel.fromMap(
    Map<String, dynamic> map,
    String id,
    double distance,
    double matchPercentage,
  ) {
    return NearbyMatchModel(
      id: id,
      fullName: map['fullName'] ?? 'Unknown',
      profileImageUrl: map['profileImageUrl'],
      distance: distance,
      matchPercentage: matchPercentage,
      address: map['address'],
      age: map['age'] ?? 18,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
