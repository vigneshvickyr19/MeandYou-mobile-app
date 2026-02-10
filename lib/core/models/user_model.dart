import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String? phoneNumber;
  final bool isProfileComplete;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;
  final String? voipToken;
  final String? fullName;
  final String? profileImageUrl;
  final bool isOnline;
  final int? age;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? geohash;
  final List<String> interests;
  final Map<String, dynamic>? preferences;
  final List<String> blockedUsers;
  final List<String> swipedUsers;
  final String? gender;
  final DateTime? lastLocationUpdate;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.isProfileComplete = false,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.voipToken,
    this.fullName,
    this.profileImageUrl,
    this.isOnline = false,
    this.age,
    this.latitude,
    this.longitude,
    this.address,
    this.geohash,
    this.interests = const [],
    this.preferences,
    this.blockedUsers = const [],
    this.swipedUsers = const [],
    this.gender,
    this.lastLocationUpdate,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data[FirebaseConstants.email] ?? '',
      phoneNumber: data[FirebaseConstants.phoneNumber],
      isProfileComplete: data[FirebaseConstants.isProfileComplete] ?? false,
      isVerified: data[FirebaseConstants.isVerified] ?? false,
      createdAt: (data[FirebaseConstants.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirebaseConstants.updatedAt] as Timestamp?)?.toDate(),
      fcmToken: data[FirebaseConstants.fcmToken],
      voipToken: data[FirebaseConstants.voipToken],
      fullName: data[FirebaseConstants.fullName],
      profileImageUrl: data[FirebaseConstants.profileImageUrl],
      isOnline: data[FirebaseConstants.isOnline] ?? false,
      age: data[FirebaseConstants.age] is int
          ? data[FirebaseConstants.age]
          : int.tryParse(data[FirebaseConstants.age]?.toString() ?? ''),
      latitude: (data[FirebaseConstants.latitude] as num?)?.toDouble(),
      longitude: (data[FirebaseConstants.longitude] as num?)?.toDouble(),
      address: data[FirebaseConstants.address],
      geohash: data[FirebaseConstants.geohash],
      interests: List<String>.from(data[FirebaseConstants.interests] ?? []),
      preferences: data[FirebaseConstants.preferences] as Map<String, dynamic>?,
      blockedUsers: List<String>.from(
        data[FirebaseConstants.blockedUsers] ?? [],
      ),
      swipedUsers: List<String>.from(data[FirebaseConstants.swipedUsers] ?? []),
      gender: data[FirebaseConstants.gender],
      lastLocationUpdate:
          (data[FirebaseConstants.lastLocationUpdate] as Timestamp?)?.toDate(),
      role: data[FirebaseConstants.role] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.email: email,
      FirebaseConstants.phoneNumber: phoneNumber,
      FirebaseConstants.isProfileComplete: isProfileComplete,
      FirebaseConstants.isVerified: isVerified,
      FirebaseConstants.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
      FirebaseConstants.fcmToken: fcmToken,
      FirebaseConstants.voipToken: voipToken,
      FirebaseConstants.fullName: fullName,
      FirebaseConstants.profileImageUrl: profileImageUrl,
      FirebaseConstants.isOnline: isOnline,
      FirebaseConstants.age: age,
      FirebaseConstants.latitude: latitude,
      FirebaseConstants.longitude: longitude,
      FirebaseConstants.address: address,
      FirebaseConstants.geohash: geohash,
      FirebaseConstants.interests: interests,
      FirebaseConstants.preferences: preferences,
      FirebaseConstants.blockedUsers: blockedUsers,
      FirebaseConstants.swipedUsers: swipedUsers,
      FirebaseConstants.gender: gender,
      FirebaseConstants.lastLocationUpdate: lastLocationUpdate != null
          ? Timestamp.fromDate(lastLocationUpdate!)
          : null,
      FirebaseConstants.role: role,
    };
  }

  UserModel copyWith({
    String? email,
    String? phoneNumber,
    bool? isProfileComplete,
    bool? isVerified,
    String? fcmToken,
    String? voipToken,
    String? fullName,
    String? profileImageUrl,
    bool? isOnline,
    int? age,
    double? latitude,
    double? longitude,
    String? address,
    String? geohash,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    List<String>? blockedUsers,
    List<String>? swipedUsers,
    String? gender,
    DateTime? lastLocationUpdate,
    String? role,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline ?? this.isOnline,
      age: age ?? this.age,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      geohash: geohash ?? this.geohash,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      swipedUsers: swipedUsers ?? this.swipedUsers,
      gender: gender ?? this.gender,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      role: role ?? this.role,
    );
  }
}
