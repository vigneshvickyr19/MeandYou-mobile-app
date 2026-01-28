import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _profileSetupCollection => _db.collection('profileSetup');

  // Create or Update User Account (Core only)
  Future<void> saveUserAccount(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error saving user account: $e');
      rethrow;
    }
  }

  // Save full profile setup
  Future<void> saveProfileSetup(ProfileModel profile) async {
    try {
      await _profileSetupCollection.doc(profile.userId).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error saving profile setup: $e');
      rethrow;
    }
  }

  // Get User Core Data
  Future<UserModel?> getUserAccount(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user account: $e');
      rethrow;
    }
  }

  // Get Profile Setup Data
  Future<ProfileModel?> getProfileSetup(String uid) async {
    try {
      DocumentSnapshot doc = await _profileSetupCollection.doc(uid).get();
      if (doc.exists) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile setup: $e');
      rethrow;
    }
  }

  // Update specific user field
  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user field: $e');
      rethrow;
    }
  }

  // Stream of user account
  Stream<UserModel?> streamUserAccount(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
  // Save User Location
  Future<void> saveUserLocation(String userId, double lat, double lng) async {
    try {
      await _db.collection('current_locations').doc(userId).set({
        'latitude': lat,
        'longitude': lng,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }
}
