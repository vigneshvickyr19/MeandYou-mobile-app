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
    );
  }
}
