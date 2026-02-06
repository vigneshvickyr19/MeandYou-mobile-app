import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../services/notification_service.dart';
import '../services/deep_link_service.dart';

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
        isProfileComplete: true, 
        isVerified: initialUser.emailVerified || (initialUser.phoneNumber != null),
        createdAt: DateTime.now(),
        role: 'user', // Basic user by default
      );
      _isInitializing = false;
      // Signal immediately for pre-warmed session
      DeepLinkService().setAuthResolved(true);
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
      if (_currentUser?.id == user.uid && !_isInitializing && _userDocumentSubscription != null) return;

      // Create a minimal user model from Firebase Auth data
      // This allows immediate navigation to Home without waiting for Firestore
      _currentUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        isProfileComplete: true, // Optimistically true, corrected after fetch
        isVerified: user.emailVerified || (user.phoneNumber != null),
        createdAt: DateTime.now(),
        role: 'user', // Basic user by default
      );
      
      _setInitialized();
      
      // Start real-time streaming of user document
      _startUserStreaming(user.uid);
    });
  }

  void _startUserStreaming(String uid) {
    _userDocumentSubscription?.cancel();
    _userDocumentSubscription = _userRepository.streamUserAccount(uid).listen((userData) {
      if (userData != null) {
        _currentUser = userData;
        notifyListeners();
      } else {
        // Handle case where document doesn't exist yet (new account)
        _currentUser = _currentUser?.copyWith(isProfileComplete: false);
        notifyListeners();
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

  // --- Login with Email ---
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.signInWithEmail(email, password);
      await _updateFcmToken();
    } finally {
      _setLoading(false);
    }
  }

  // --- Sign Up with Email ---
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.signUpWithEmail(
        email: email,
        password: password,
      );
      await _updateFcmToken();
    } finally {
      _setLoading(false);
    }
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

  // --- Login with Phone ---
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

  // --- Verify Phone OTP ---
  Future<void> verifyOtp(String verificationId, String smsCode) async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.verifyAndLoginOtp(
        verificationId,
        smsCode,
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
      await _userRepository.signOut();
      _currentUser = null;
      // Reset auth resolution for next login/session
      DeepLinkService().setAuthResolved(false);
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
      await _userRepository.updateOnlineStatus(_currentUser!.id, isOnline);
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
