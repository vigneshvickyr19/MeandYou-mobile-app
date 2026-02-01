import 'package:flutter/foundation.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

class GetCurrentUserProfileUseCase {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> call(UserModel user) async {
    try {
      final ProfileModel? profile = await _databaseService.getProfileSetup(user.id);
      
      // Fetch location data directly from profileSetup document
      final profileDoc = await _firestore
          .collection(FirebaseConstants.profileSetup)
          .doc(user.id)
          .get();
      
      final profileData = profileDoc.data();
      
      if (profile != null) {
        return user.copyWith(
          fullName: profile.fullName,
          interests: profile.interests,
          gender: profile.gender,
          address: profile.city,
          // Include location data from profileSetup document
          latitude: (profileData?[FirebaseConstants.latitude] as num?)?.toDouble(),
          longitude: (profileData?[FirebaseConstants.longitude] as num?)?.toDouble(),
          geohash: profileData?[FirebaseConstants.geohash] as String?,
          preferences: {
            'lookingFor': profile.lookingFor,
            'minAge': profile.minAge,
            'maxAge': profile.maxAge,
            'distance': profile.distance,
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting current user profile: $e');
      }
    }
    return user;
  }
}
