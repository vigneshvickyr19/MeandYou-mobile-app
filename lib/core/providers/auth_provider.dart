import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../services/notification_service.dart';
import '../services/deep_link_service.dart';
import '../services/storage_service.dart';
import '../services/presence_service.dart';
import '../services/background_location_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  StreamSubscription<UserModel?>? _userDocumentSubscription;

  // Guards to prevent duplicate side-effects on repeated stream emissions
  bool _subscriptionsSynced = false;
  bool _trackingStarted = false;
  bool _authResolved = false; // ensures DeepLinkService is only notified once

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Standard non-throwing check for Firebase initialization
    if (Firebase.apps.isNotEmpty) {
      initialize();
    }
  }


  void initialize() {
    if (!_isInitializing && _currentUser != null) return;
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
          _userDocumentSubscription != null) {
        return;
      }

      final isFirstInit = _isInitializing;
      
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

      // Only show full-screen initialization on first app boot
      if (isFirstInit) {
        _isInitializing = true;
        notifyListeners();
      }

      // Start real-time streaming of user document
      _startUserStreaming(user.uid);
    });
  }

  void _startUserStreaming(String uid) {
    _userDocumentSubscription?.cancel();
    
    // Initialize Presence (RTDB) when user document starts streaming
    PresenceService.instance.initialize(uid);

    // Reset per-session guards when starting a new user stream
    _subscriptionsSynced = false;
    _trackingStarted = false;
    _authResolved = false;

    _userDocumentSubscription = _userRepository.streamUserAccount(uid).listen((
      userData,
    ) {
      if (userData != null) {
        _currentUser = userData;

        // Ensure subscriptions are synced — only once per login session
        _syncSubscriptions();

        _setInitialized();
      } else {
        // Handle case where document doesn't exist yet (new account)
        _currentUser = _currentUser?.copyWith(isProfileComplete: false);
        _setInitialized();
      }
    }, onError: (e) {
      debugPrint("AuthProvider: User stream error: $e");
      _setInitialized();
    });
  }

  /// Syncs FCM topic subscriptions based on current user profile.
  /// Runs only once per login session — subsequent Firestore updates are ignored.
  Future<void> _syncSubscriptions() async {
    if (_currentUser == null || _subscriptionsSynced) return;
    _subscriptionsSynced = true;

    // 1. Update FCM Token to Firestore
    await _updateFcmToken();

    // 2. Subscribe to topics
    await NotificationService.instance.subscribeToGlobalTopic();

    if (_currentUser?.gender != null) {
      await NotificationService.instance.subscribeToGenderTopic(_currentUser!.gender!);
      debugPrint("AuthProvider: Synced gender subscription for ${_currentUser!.gender}");
    }
  }

  void _setInitialized() {
    // Only signal auth resolution once — every Firestore stream emit re-calls this
    if (!_authResolved) {
      _authResolved = true;
      DeepLinkService().setAuthResolved(_currentUser != null);
    }

    if (_isInitializing) {
      _isInitializing = false;

      // Start background location tracking once per login session
      if (_currentUser != null && !_trackingStarted) {
        _trackingStarted = true;
        BackgroundLocationService.instance.startTracking(_currentUser!.id);
      }

      notifyListeners();
    } else {
      // Standard data update, not a routing gate event
      notifyListeners();
    }
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
      // Removed manual _updateFcmToken() call as it's now handled in the unified _syncSubscriptions()
      // triggered when the user document starts streaming.
      
      // Sync all subscriptions
      await _syncSubscriptions();
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
      
      // Unsubscribe from global notifications
      await NotificationService.instance.unsubscribeFromGlobalTopic();

      // Unsubscribe from gender topic if available
      if (_currentUser?.gender != null) {
        await NotificationService.instance.unsubscribeFromGenderTopic(_currentUser!.gender!);
      }

      // Clear topic subscription cache so next login re-subscribes correctly
      NotificationService.instance.clearSubscriptionState();

      await _userRepository.signOut();
      _currentUser = null;

      // Reset session guards
      _subscriptionsSynced = false;
      _trackingStarted = false;

      // Stop background location tracking on logout
      BackgroundLocationService.instance.stopTracking();

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
      
      // Unsubscribe from global notifications
      await NotificationService.instance.unsubscribeFromGlobalTopic();

      // Unsubscribe from gender topic if available
      if (_currentUser?.gender != null) {
        await NotificationService.instance.unsubscribeFromGenderTopic(_currentUser!.gender!);
      }

      // Clear topic subscription cache so next session starts fresh
      NotificationService.instance.clearSubscriptionState();

      _currentUser = null;
      _userDocumentSubscription?.cancel();

      // Reset session guards
      _subscriptionsSynced = false;
      _trackingStarted = false;

      // Stop background location tracking on account deletion
      BackgroundLocationService.instance.stopTracking();

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
      // Online state lives in RTDB only — no local state changes, no rebuild needed.
    } catch (e) {
      debugPrint("Error setting online status: $e");
    }
  }


  Future<void> _updateFcmToken() async {
    if (_currentUser == null) return;

    try {
      // Use the more robust sync method from NotificationService which handles token fetching if null
      await NotificationService.instance.syncTokenNow();
      
      // Also update VoIP Token (iOS only)
      final voipToken = await NotificationService.instance.getVoIPToken();
      if (voipToken != null) {
        await _userRepository.updateVoipToken(_currentUser!.id, voipToken);
        debugPrint("AuthProvider: VoIP Token updated for user: ${_currentUser!.id}");
      }
    } catch (e) {
      debugPrint("AuthProvider: Error updating tokens: $e");
    }
  }
}
