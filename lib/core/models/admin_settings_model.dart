import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettings {
  final int maleFreeLikes;
  final int femaleFreeLikes;
  final Map<String, int> userOverrides;
  final DateTime updatedAt;

  AdminSettings({
    this.maleFreeLikes = 5,
    this.femaleFreeLikes = 10,
    this.userOverrides = const {},
    required this.updatedAt,
  });

  factory AdminSettings.fromMap(Map<String, dynamic> data) {
    return AdminSettings(
      maleFreeLikes: data['maleFreeLikes'] ?? 5,
      femaleFreeLikes: data['femaleFreeLikes'] ?? 10,
      userOverrides: Map<String, int>.from(data['userOverrides'] ?? {}),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maleFreeLikes': maleFreeLikes,
      'femaleFreeLikes': femaleFreeLikes,
      'userOverrides': userOverrides,
      'updatedAt': updatedAt,
    };
  }
}

class Announcement {
  final String id;
  final String title;
  final String message;
  final String type; // offer, release, promotion
  final String targetAudience; // male, female, both
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetAudience = 'both',
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> data) {
    return Announcement(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'offer',
      targetAudience: data['targetAudience'] ?? 'both',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'targetAudience': targetAudience,
      'createdAt': createdAt,
    };
  }
}
