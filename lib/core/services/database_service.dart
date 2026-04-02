import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../constants/firebase_constants.dart';

class DatabaseService {
  // Use a lazy getter for Firestore instance
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Collection references using the lazy getter
  CollectionReference get _usersCollection => _db.collection(FirebaseConstants.users);
  CollectionReference get _profileSetupCollection => _db.collection(FirebaseConstants.profileSetup);


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

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating user field: $e');
      rethrow;
    }
  }

  Future<void> updateProfileFields(String uid, Map<String, dynamic> data) async {
    try {
      await _profileSetupCollection.doc(uid).set(
        {
          ...data,
          'profileUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating profile field: $e');
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
  
  // Get User by ID with Name Fallback
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        
        // Fallback for name if missing in core record
        if (user.fullName == null || user.fullName!.isEmpty) {
          final profile = await getProfileSetup(userId);
          if (profile != null && profile.fullName != null) {
            user = user.copyWith(fullName: profile.fullName, profileImageUrl: profile.photos?.first);
            // Sync back to users collection for future fast fetches
            _usersCollection.doc(userId).update({
              'fullName': profile.fullName,
              'profileImageUrl': profile.photos?.first,
            });
          }
        }
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Stream of User for Real-time Status and Name
  Stream<UserModel?> streamUserById(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
  
  
  // Save User Location
  Future<void> saveUserLocation(String userId, double lat, double lng) async {
    try {
      await _db.collection(FirebaseConstants.currentLocations).doc(userId).set({
        'latitude': lat,
        'longitude': lng,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  // Delete User Account (Firestore Documents)
  Future<void> deleteUserAccount(String userId) async {
    try {
      final batch = _db.batch();
      batch.delete(_usersCollection.doc(userId));
      batch.delete(_profileSetupCollection.doc(userId));
      batch.delete(_db.collection(FirebaseConstants.currentLocations).doc(userId));
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting user account from Firestore: $e');
      rethrow;
    }
  }
}
