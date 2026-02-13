enum SubscriptionStatus { active, expired, cancelled }

class UserSubscriptionEntity {
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime expiryDate;
  final String paymentId;
  final SubscriptionStatus status;

  const UserSubscriptionEntity({
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.expiryDate,
    required this.paymentId,
    required this.status,
  });

  bool get isPremium => status == SubscriptionStatus.active && expiryDate.isAfter(DateTime.now());
}
