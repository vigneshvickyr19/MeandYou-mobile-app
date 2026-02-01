class NearbyMatchEntity {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final double distance;
  final double matchPercentage;
  final String? address;
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
    required this.age,
    required this.latitude,
    required this.longitude,
    required this.interests,
  });
}
