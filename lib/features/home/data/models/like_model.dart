import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

class LikeModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final bool isMutual;

  LikeModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    this.isMutual = false,
  });

  factory LikeModel.fromMap(Map<String, dynamic> map, String id) {
    return LikeModel(
      id: id,
      fromUserId: map[FirebaseConstants.fromUserId] ?? '',
      toUserId: map[FirebaseConstants.toUserId] ?? '',
      createdAt: (map[FirebaseConstants.createdAt] as Timestamp).toDate(),
      isMutual: map[FirebaseConstants.isMutual] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fromUserId: fromUserId,
      FirebaseConstants.toUserId: toUserId,
      FirebaseConstants.createdAt: Timestamp.fromDate(createdAt),
      FirebaseConstants.isMutual: isMutual,
    };
  }
}
