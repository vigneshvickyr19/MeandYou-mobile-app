import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.productId,
    required super.durationType,
    required super.durationInDays,
    required super.price,
    required super.currency,
    required super.benefitIds,
    super.badge,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionPlanModel(
      id: id,
      name: map['name'] ?? '',
      productId: map['productId'] ?? 'plus',
      durationType: DurationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['durationType'],
        orElse: () => DurationType.monthly,
      ),
      durationInDays: map['durationInDays'] ?? 30,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      benefitIds: List<String>.from(map['benefitIds'] ?? []),
      badge: map['badge'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = {
      'name': name,
      'productId': productId,
      'durationType': durationType.toString().split('.').last,
      'durationInDays': durationInDays,
      'price': price,
      'currency': currency,
      'benefitIds': benefitIds,
      'badge': badge,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isUpdate || createdAt != null) {
      data['createdAt'] = createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp();
    }
    return data;
  }

  factory SubscriptionPlanModel.fromEntity(SubscriptionPlanEntity entity) {
    return SubscriptionPlanModel(
      id: entity.id,
      name: entity.name,
      productId: entity.productId,
      durationType: entity.durationType,
      durationInDays: entity.durationInDays,
      price: entity.price,
      currency: entity.currency,
      benefitIds: entity.benefitIds,
      badge: entity.badge,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
