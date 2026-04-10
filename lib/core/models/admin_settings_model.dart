import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettings {
  final int maleFreeLikes;
  final int femaleFreeLikes;
  final double nearbyRadiusInKm;
  final double maxRadiusKm;
  final int maxUsersPerFetch;
  final DateTime updatedAt;

  AdminSettings({
    this.maleFreeLikes = 5,
    this.femaleFreeLikes = 10,
    this.nearbyRadiusInKm = 10.0,
    this.maxRadiusKm = 50.0,
    this.maxUsersPerFetch = 20,
    required this.updatedAt,
  });

  factory AdminSettings.fromMap(Map<String, dynamic> data) {
    return AdminSettings(
      maleFreeLikes: data['maleFreeLikes'] ?? 5,
      femaleFreeLikes: data['femaleFreeLikes'] ?? 10,
      nearbyRadiusInKm: (data['nearbyRadiusInKm'] as num?)?.toDouble() ?? 10.0,
      maxRadiusKm: (data['maxRadiusKm'] as num?)?.toDouble() ?? 50.0,
      maxUsersPerFetch: data['maxUsersPerFetch'] ?? 20,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maleFreeLikes': maleFreeLikes,
      'femaleFreeLikes': femaleFreeLikes,
      'nearbyRadiusInKm': nearbyRadiusInKm,
      'maxRadiusKm': maxRadiusKm,
      'maxUsersPerFetch': maxUsersPerFetch,
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
