import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../services/notification_service.dart';
import '../services/deep_link_service.dart';
import '../services/storage_service.dart';
import '../services/presence_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  StreamSubscription<UserModel?>? _userDocumentSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({User? initialUser}) {
    if (initialUser != null) {
      _currentUser = UserModel(
        id: initialUser.uid,
        email: initialUser.email ?? '',
        phoneNumber: initialUser.phoneNumber,
        isProfileComplete: false,
        isVerified:
            initialUser.emailVerified || (initialUser.phoneNumber != null),
        createdAt: DateTime.now(),
        role: 'user', // Basic user by default
      );
    }
    _init();
  }

  void _init() {
    // 1. Listen for auth changes
    _userRepository.authStateChanges.listen((User? user) async {
      if (user == null) {
        _userDocumentSubscription?.cancel();
        _currentUser = null;
        _isInitializing = false; // Ensure we stop initializing
        _setInitialized();
        return;
      }

      // Skip if we already have this user and subscription is active to avoid flicker
      if (_currentUser?.id == user.uid &&
          !_isInitializing &&
          _userDocumentSubscription != null)
        return;

      // Create a minimal user model from Firebase Auth data
      // This allows immediate navigation to Home without waiting for Firestore
      _currentUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        isProfileComplete: false, // Default to false until Firestore confirms
        isVerified: user.emailVerified || (user.phoneNumber != null),
        createdAt: DateTime.now(),
        role: 'user',
      );

      _isInitializing = true;
      notifyListeners();

      // Start real-time streaming of user document
      _startUserStreaming(user.uid);
    });
  }

  void _startUserStreaming(String uid) {
    _userDocumentSubscription?.cancel();
    
    // Initialize Presence (RTDB) when user document starts streaming
    PresenceService.instance.initialize(uid);

    _userDocumentSubscription = _userRepository.streamUserAccount(uid).listen((
      userData,
    ) {
      if (userData != null) {
        _currentUser = userData;
        _setInitialized();
      } else {
        // Handle case where document doesn't exist yet (new account)
        _currentUser = _currentUser?.copyWith(isProfileComplete: false);
        _setInitialized();
      }
    });
  }

  void _setInitialized() {
    // Always signal that state is stable
    DeepLinkService().setAuthResolved(true);

    if (_isInitializing) {
      _isInitializing = false;
    }
    notifyListeners();
  }

  // --- Login with Phone (Request OTP) ---
  Future<void> loginWithPhone(
    String phoneNumber,
    Function(String, int?) codeSent, {
    Function(String)? onError,
    VoidCallback? onAutoVerify,
  }) async {
    _setLoading(true);
    try {
      await _userRepository.requestOtp(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          _setLoading(false);
          codeSent(verificationId, resendToken);
        },
        verificationFailed: (e) {
          _setLoading(false);
          if (onError != null) {
            String msg = e.message ?? 'Verification failed';
            if (e.code == 'invalid-phone-number') {
              msg = "Invalid phone number format.";
            }
            if (e.code == 'too-many-requests') {
              msg = "Too many attempts. Try again later.";
            }
            onError(msg);
          }
        },
        verificationCompleted: (credential) {
          _setLoading(false);
          if (onAutoVerify != null) onAutoVerify();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _setLoading(false);
        },
      );
    } catch (e) {
      _setLoading(false);
      if (onError != null) onError(e.toString());
      rethrow;
    }
  }

  // --- Send OTP Wrapper ---
  Future<void> sendOtp(String phoneNumber) async {
    final completer = Completer<void>();

    await loginWithPhone(
      phoneNumber,
      (verificationId, resendToken) {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    return completer.future;
  }

  // --- Login with Google ---
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.signInWithGoogle();
      await _updateFcmToken();
    } finally {
      _setLoading(false);
    }
  }

  // --- Verify Phone OTP ---
  Future<void> verifyOtp(
    String verificationId,
    String smsCode, {
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.verifyAndLoginOtp(
        verificationId,
        smsCode,
        displayName: displayName,
      );
      await _updateFcmToken();
    } finally {
      _setLoading(false);
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    _setLoading(true);
    try {
      _userDocumentSubscription?.cancel();
      // Clear presence on sign out
      PresenceService.instance.setStatus(false);
      PresenceService.instance.dispose();
      
      await _userRepository.signOut();
      _currentUser = null;
      // Reset auth resolution for next login/session
      DeepLinkService().setAuthResolved(false);
    } finally {
      _setLoading(false);
    }
  }

  // --- Delete Account & Cleanup ---
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    
    final userId = _currentUser!.id;
    _setLoading(true);

    try {
      // 0. Cleanup Presence
      PresenceService.instance.dispose();
      
      // 1. Cleanup Storage (Scoped folders)
      await StorageService.instance.deleteUserStorageDetails(userId);

      // 2. Cleanup Firestore (User & Profile docs)
      await _userRepository.deleteUserAccount(userId);

      // 3. Delete Firebase Auth User
      // Note: Re-authentication might be required by Firebase for sensitive ops
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == userId) {
         await user.delete();
      }

      _currentUser = null;
      _userDocumentSubscription?.cancel();
      DeepLinkService().setAuthResolved(false);
      
      debugPrint('Account deleted successfully for user: $userId');
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _userDocumentSubscription?.cancel();
    super.dispose();
  }

  // --- Update User Account (Status/Meta) ---
  Future<void> updateAccountStatus(UserModel updatedUser) async {
    _setLoading(true);
    try {
      await _userRepository.updateUserAccount(updatedUser);
      _currentUser = updatedUser;
    } finally {
      _setLoading(false);
    }
  }

  void updateUserLocally(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updateLocation(double lat, double lng) async {
    if (_currentUser == null) return;
    try {
      await _userRepository.saveUserLocation(_currentUser!.id, lat, lng);
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (_currentUser == null) return;
    try {
      await PresenceService.instance.setStatus(isOnline);
      // We still update Firestore for "last seen" if needed, 
      // but the real-time "Online" state is now in RTDB.
      _currentUser = _currentUser!.copyWith(isOnline: isOnline);
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting online status: $e");
    }
  }

  Future<void> _updateFcmToken() async {
    if (_currentUser == null) return;

    // Update FCM Token
    final token = NotificationService.instance.fcmToken;
    if (token != null) {
      try {
        await _userRepository.updateFcmToken(_currentUser!.id, token);
        debugPrint("FCM Token updated for user: ${_currentUser!.id}");
      } catch (e) {
        debugPrint("Error updating FCM token: $e");
      }
    }

    // Update VoIP Token (iOS only)
    final voipToken = await NotificationService.instance.getVoIPToken();
    if (voipToken != null) {
      try {
        await _userRepository.updateVoipToken(_currentUser!.id, voipToken);
        debugPrint("VoIP Token updated for user: ${_currentUser!.id}");
      } catch (e) {
        debugPrint("Error updating VoIP token: $e");
      }
    }
  }
}
