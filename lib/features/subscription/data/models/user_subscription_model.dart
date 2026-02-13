import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_subscription_entity.dart';

class UserSubscriptionModel extends UserSubscriptionEntity {
  const UserSubscriptionModel({
    required super.userId,
    required super.planId,
    required super.startDate,
    required super.expiryDate,
    required super.paymentId,
    required super.status,
  });

  factory UserSubscriptionModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserSubscriptionModel(
      userId: userId,
      planId: map['planId'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentId: map['paymentId'] ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'paymentId': paymentId,
      'status': status.toString().split('.').last,
    };
  }

  factory UserSubscriptionModel.fromEntity(UserSubscriptionEntity entity) {
    return UserSubscriptionModel(
      userId: entity.userId,
      planId: entity.planId,
      startDate: entity.startDate,
      expiryDate: entity.expiryDate,
      paymentId: entity.paymentId,
      status: entity.status,
    );
  }
}
