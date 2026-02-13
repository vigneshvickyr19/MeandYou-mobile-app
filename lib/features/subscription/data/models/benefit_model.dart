import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/benefit_entity.dart';

class BenefitModel extends BenefitEntity {
  const BenefitModel({
    required super.id,
    required super.title,
    required super.code,
    required super.description,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory BenefitModel.fromMap(Map<String, dynamic> map, String id) {
    return BenefitModel(
      id: id,
      title: map['title'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = {
      'title': title,
      'code': code,
      'description': description,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isUpdate || createdAt != null) {
      data['createdAt'] = createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp();
    }
    return data;
  }

  factory BenefitModel.fromEntity(BenefitEntity entity) {
    return BenefitModel(
      id: entity.id,
      title: entity.title,
      code: entity.code,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
