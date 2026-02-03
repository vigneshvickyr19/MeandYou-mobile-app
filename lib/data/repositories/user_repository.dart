import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../core/models/profile_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';

class UserRepository {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // Get current user stream
  Stream<User?> get authStateChanges => _authService.user;

  // Get current user synchronously
  User? get currentUser => _authService.currentUser;

  // Sign up with Email and create profile
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _authService.signUpWithEmail(
      email,
      password,
    );
    String uid = credential.user!.uid;

    UserModel newUser = UserModel(
      id: uid,
      email: email,
      isProfileComplete: false,
      isVerified: false,
      createdAt: DateTime.now(),
    );

    await _dbService.saveUserAccount(newUser);
    return newUser;
  }

  // Sign in with Email
  Future<UserModel?> signInWithEmail(String email, String password) async {
    UserCredential credential = await _authService.signInWithEmail(
      email,
      password,
    );
    return await _dbService.getUserAccount(credential.user!.uid);
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    UserCredential credential = await _authService.signInWithGoogle();
    String uid = credential.user!.uid;

    UserModel? existing = await _dbService.getUserAccount(uid);
    if (existing == null) {
      existing = UserModel(
        id: uid,
        email: credential.user?.email ?? '',
        phoneNumber: credential.user?.phoneNumber,
        isProfileComplete: false,
        isVerified: false,
        createdAt: DateTime.now(),
      );
      await _dbService.saveUserAccount(existing);
    }
    return existing;
  }

  // OTP Verification flows
  Future<void> requestOtp({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _authService.signInWithCredential(credential);
          User? user = _authService.currentUser;
          if (user != null) {
            UserModel? existing = await _dbService.getUserAccount(user.uid);
            if (existing == null) {
              existing = UserModel(
                id: user.uid,
                email: user.email ?? '',
                phoneNumber: user.phoneNumber,
                isProfileComplete: false,
                isVerified: true,
                createdAt: DateTime.now(),
              );
              await _dbService.saveUserAccount(existing);
            }
          }
          verificationCompleted(credential);
        } catch (e) {
          debugPrint("Error in verificationCompleted: $e");
        }
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserModel> verifyAndLoginOtp(
    String verificationId,
    String smsCode,
  ) async {
    UserCredential credential = await _authService.signInWithOtp(
      verificationId,
      smsCode,
    );
    String uid = credential.user!.uid;

    UserModel? existing = await _dbService.getUserAccount(uid);
    if (existing == null) {
      existing = UserModel(
        id: uid,
        email: credential.user?.email ?? '',
        phoneNumber: credential.user?.phoneNumber,
        isProfileComplete: false,
        isVerified: true, // Phone verified by default
        createdAt: DateTime.now(),
      );
      await _dbService.saveUserAccount(existing);
    }
    return existing;
  }

  // Update Profile Setup (New collection)
  Future<void> saveProfileSetup(ProfileModel profile) async {
    await _dbService.saveProfileSetup(profile);
  }

  // Update User Core Data
  Future<void> updateUserAccount(UserModel user) async {
    await _dbService.saveUserAccount(user);
  }

  // Get User Core Data
  Future<UserModel?> getUserAccount(String uid) async {
    return await _dbService.getUserAccount(uid);
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Save Location
  Future<void> saveUserLocation(String userId, double lat, double lng) async {
    await _dbService.saveUserLocation(userId, lat, lng);
  }

  // Update FCM Token
  Future<void> updateFcmToken(String userId, String token) async {
    await _dbService.updateUserField(userId, {'fcmToken': token});
  }

  // Update VoIP Token
  Future<void> updateVoipToken(String userId, String token) async {
    await _dbService.updateUserField(userId, {'voipToken': token});
  }

  // Update Online Status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _dbService.updateOnlineStatus(userId, isOnline);
  }
}
