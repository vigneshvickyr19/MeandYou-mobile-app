enum DurationType { weekly, monthly, quarterly }

class SubscriptionPlanEntity {
  final String id;
  final String name; // Display name for the specific duration (e.g. 1 Month)
  final String productId; // Grouping ID (e.g., plus, premium, ultra)
  final DurationType durationType;
  final int durationInDays;
  final double price;
  final String currency;
  final List<String> benefitIds;
  final String? badge;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.productId,
    required this.durationType,
    required this.durationInDays,
    required this.price,
    required this.currency,
    required this.benefitIds,
    this.badge,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
}
