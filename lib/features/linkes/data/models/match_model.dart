import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String userId1;
  final String userId2;

  MatchModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.userId1,
    required this.userId2,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'userId1': userId1,
      'userId2': userId2,
    };
  }

  String getOtherUserId(String currentUserId) {
    return participants.firstWhere((id) => id != currentUserId, orElse: () => '');
  }
}
