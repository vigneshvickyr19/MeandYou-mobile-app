class NearbyMatchEntity {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final double distance;
  final double matchPercentage;
  final String? address;
  final String? landmark;
  final String? area;
  final String? fullAddress;
  final int age;
  final double latitude;
  final double longitude;
  final List<String> interests;

  const NearbyMatchEntity({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    required this.distance,
    required this.matchPercentage,
    this.address,
    this.landmark,
    this.area,
    this.fullAddress,
    required this.age,
    required this.latitude,
    required this.longitude,
    required this.interests,
  });

  NearbyMatchEntity copyWith({
    String? id,
    String? fullName,
    String? profileImageUrl,
    double? distance,
    double? matchPercentage,
    String? address,
    String? landmark,
    String? area,
    String? fullAddress,
    int? age,
    double? latitude,
    double? longitude,
    List<String>? interests,
  }) {
    return NearbyMatchEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      distance: distance ?? this.distance,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      area: area ?? this.area,
      fullAddress: fullAddress ?? this.fullAddress,
      age: age ?? this.age,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      interests: interests ?? this.interests,
    );
  }
}
