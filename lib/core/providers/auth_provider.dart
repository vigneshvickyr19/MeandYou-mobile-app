import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _userRepository.authStateChanges.listen((User? user) async {
      try {
        if (user != null) {
          _currentUser = await _userRepository.getUserAccount(user.uid);
          if (_currentUser == null) {
            // Fallback: Create new user if not found in DB
            final newUser = UserModel(
              id: user.uid,
              email: user.email ?? '',
              phoneNumber: user.phoneNumber,
              isProfileComplete: false,
              isVerified: user.emailVerified || (user.phoneNumber != null),
              createdAt: DateTime.now(),
            );
            await _userRepository.updateUserAccount(newUser); // Save to DB
            _currentUser = newUser;
          }
          await _updateFcmToken();
        } else {
          _currentUser = null;
        }
      } catch (e) {
        debugPrint("Error during AuthProvider initialization: $e");
        _currentUser = null;
      } finally {
        _isInitializing = false;
        notifyListeners();
      }
    });
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
      await _userRepository.signOut();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
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
