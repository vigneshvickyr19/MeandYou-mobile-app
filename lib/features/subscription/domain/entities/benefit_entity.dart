class BenefitEntity {
  final String id;
  final String title;
  final String code; // Unique identifier for logical checks (e.g. UNLIMITED_LIKES)
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BenefitEntity({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
}
