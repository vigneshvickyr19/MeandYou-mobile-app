import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Service to initialize and manage Firebase
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) {      }
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      if (kDebugMode) {      }
    } catch (e) {
      if (kDebugMode) {      }
      rethrow;
    }
  }
}
