import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class StartupProvider extends ChangeNotifier {
  bool _isSplashDone = false;
  bool _isNotificationLaunch = false;

  bool get isSplashDone => _isSplashDone;
  bool get isNotificationLaunch => _isNotificationLaunch;

  StartupProvider() {
    _init();
  }

  void _init() {
    // Check if launched from notification
    // Verify instance is ready, although main.dart ensures initialize() is called.
    final hasInitialNotification = NotificationService.instance.initialMessage != null;

    if (hasInitialNotification) {
      _isNotificationLaunch = true;
      _isSplashDone = true; 
      // No notifyListeners here because we are in constructor, 
      // initial state is set before anyone listens.
    } else {
      // Normal splash timer
      // We start with _isSplashDone = false (default)
      Timer(const Duration(seconds: 4), () {
        _isSplashDone = true;
        notifyListeners();
      });
    }
  }
}
