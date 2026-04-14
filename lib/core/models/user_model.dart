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
  final String? thumbnailUrl;
  final int? imageVersion;
  final int? age;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? geohash;
  final String? gender;
  final DateTime? lastLocationUpdate;
  final String role;
  final String? lookingFor;
  final int? minAge;
  final int? maxAge;
  final DateTime? lastActiveAt;

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
    this.thumbnailUrl,
    this.imageVersion,
    this.age,
    this.latitude,
    this.longitude,
    this.address,
    this.geohash,
    this.gender,
    this.lastLocationUpdate,
    this.role = 'user',
    this.lookingFor,
    this.minAge,
    this.maxAge,
    this.lastActiveAt,
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
      thumbnailUrl: data[FirebaseConstants.thumbnailUrl],
      imageVersion: data[FirebaseConstants.imageVersion],
      age: data[FirebaseConstants.age] is int
          ? data[FirebaseConstants.age]
          : int.tryParse(data[FirebaseConstants.age]?.toString() ?? ''),
      latitude: (data[FirebaseConstants.latitude] as num?)?.toDouble(),
      longitude: (data[FirebaseConstants.longitude] as num?)?.toDouble(),
      address: data[FirebaseConstants.address],
      geohash: data[FirebaseConstants.geohash],
      gender: data[FirebaseConstants.gender],
      lastLocationUpdate:
          (data[FirebaseConstants.lastLocationUpdate] as Timestamp?)?.toDate(),
      role: data[FirebaseConstants.role] ?? 'user',
      lookingFor: data[FirebaseConstants.lookingFor],
      minAge: data[FirebaseConstants.minAge] is int
          ? data[FirebaseConstants.minAge]
          : int.tryParse(data[FirebaseConstants.minAge]?.toString() ?? ''),
      maxAge: data[FirebaseConstants.maxAge] is int
          ? data[FirebaseConstants.maxAge]
          : int.tryParse(data[FirebaseConstants.maxAge]?.toString() ?? ''),
      lastActiveAt: (data[FirebaseConstants.lastActiveAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
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
      FirebaseConstants.role: role,
    };

    if (fullName != null) map[FirebaseConstants.fullName] = fullName;
    if (profileImageUrl != null) map[FirebaseConstants.profileImageUrl] = profileImageUrl;
    if (thumbnailUrl != null) map[FirebaseConstants.thumbnailUrl] = thumbnailUrl;
    if (imageVersion != null) map[FirebaseConstants.imageVersion] = imageVersion;
    if (age != null) map[FirebaseConstants.age] = age;
    if (latitude != null) map[FirebaseConstants.latitude] = latitude;
    if (longitude != null) map[FirebaseConstants.longitude] = longitude;
    if (address != null) map[FirebaseConstants.address] = address;
    if (geohash != null) map[FirebaseConstants.geohash] = geohash;
    if (gender != null) map[FirebaseConstants.gender] = gender;
    if (lastLocationUpdate != null) {
      map[FirebaseConstants.lastLocationUpdate] = Timestamp.fromDate(lastLocationUpdate!);
    }
    if (lookingFor != null) map[FirebaseConstants.lookingFor] = lookingFor;
    if (minAge != null) map[FirebaseConstants.minAge] = minAge;
    if (maxAge != null) map[FirebaseConstants.maxAge] = maxAge;
    if (lastActiveAt != null) {
      map[FirebaseConstants.lastActiveAt] = Timestamp.fromDate(lastActiveAt!);
    } else {
      map[FirebaseConstants.lastActiveAt] = FieldValue.serverTimestamp();
    }

    return map;
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
    String? thumbnailUrl,
    int? imageVersion,
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
    String? lookingFor,
    int? minAge,
    int? maxAge,
    DateTime? lastActiveAt,
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
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageVersion: imageVersion ?? this.imageVersion,
      age: age ?? this.age,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      geohash: geohash ?? this.geohash,
      gender: gender ?? this.gender,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      role: role ?? this.role,
      lookingFor: lookingFor ?? this.lookingFor,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
