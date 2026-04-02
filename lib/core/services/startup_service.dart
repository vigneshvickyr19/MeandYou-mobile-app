import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'deep_link_service.dart';

class StartupService {
  static final StartupService _instance = StartupService._internal();
  static StartupService get instance => _instance;
  
  StartupService._internal();

  // Startup state
  bool _isInitialized = false;
  bool _isSplashComplete = false;
  StartupRoute? _targetRoute;
  
  // Launch context
  LaunchContext? _launchContext;
  
  bool get isInitialized => _isInitialized;
  bool get isSplashComplete => _isSplashComplete;
  StartupRoute? get targetRoute => _targetRoute;
  LaunchContext? get launchContext => _launchContext;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('StartupService: Beginning initialization');
      
      // 2. Wait for NotificationService to be ready
      // This is crucial because it fetches the initialMessage we need for detection
      await NotificationService.instance.initialize();
      
      // Determine how the app was launched
      _launchContext = await _detectLaunchContext();

      
      // For notification/deep link launches, we still show the splash for branding
      // but we mark them as special in the launchContext so AppStateProvider knows
      
      _isInitialized = true;
      debugPrint('StartupService: Initialization complete');
    } catch (e) {
      debugPrint('StartupService: Initialization error: $e');
      // Default to normal launch on error
      _launchContext = LaunchContext(
        type: LaunchType.normal,
        data: {},
      );
      _isInitialized = true; // Mark as initialized to prevent blocking
    }
  }

  /// Detect how the app was launched
  /// Safe to call before Firebase is fully initialized
  Future<LaunchContext> _detectLaunchContext() async {
    try {
      // Check for push notification launch
      final initialMessage = NotificationService.instance.initialMessage;
      if (initialMessage != null) {
        return LaunchContext(
          type: LaunchType.pushNotification,
          data: initialMessage.data,
        );
      }
    } catch (e) {
      debugPrint('StartupService: Error checking notification launch: $e');
    }

    try {
      // Check for deep link launch
      final hasPendingDeepLink = DeepLinkService().hasPendingNotification;
      if (hasPendingDeepLink) {
        return LaunchContext(
          type: LaunchType.deepLink,
          data: {},
        );
      }
    } catch (e) {
      debugPrint('StartupService: Error checking deep link launch: $e');
    }

    // Normal cold start
    return LaunchContext(
      type: LaunchType.normal,
      data: {},
    );
  }

  /// Complete the splash screen (called after timer or immediately for special launches)
  void completeSplash() {
    _isSplashComplete = true;
    debugPrint('StartupService: Splash completed');
  }

  /// Determine the target route based on app state
  StartupRoute determineTargetRoute({
    required bool isAuthenticated,
    required bool isProfileComplete,
    required bool hasLocationAccess,
    required bool hasGeohash,
  }) {
    debugPrint('StartupService: Determining route - Auth: $isAuthenticated, Profile: $isProfileComplete, Location: $hasLocationAccess, Geohash: $hasGeohash');

    // Not authenticated -> Get Started
    if (!isAuthenticated) {
      _targetRoute = StartupRoute.getStarted;
      return _targetRoute!;
    }

    // Authenticated but profile incomplete -> Profile Setup
    if (!isProfileComplete) {
      _targetRoute = StartupRoute.profileSetup;
      return _targetRoute!;
    }

    // Special case: Launched from notification -> Go directly to home
    // Skip location checks to allow immediate navigation
    if (_launchContext?.type == LaunchType.pushNotification ||
        _launchContext?.type == LaunchType.deepLink) {
      _targetRoute = StartupRoute.home;
      return _targetRoute!;
    }

    // Check location access
    if (!hasLocationAccess || !hasGeohash) {
      _targetRoute = StartupRoute.locationPermission;
      return _targetRoute!;
    }

    // All checks passed -> Home
    _targetRoute = StartupRoute.home;
    return _targetRoute!;
  }

  /// Reset the service (useful for testing or logout)
  void reset() {
    _isInitialized = false;
    _isSplashComplete = false;
    _targetRoute = null;
    _launchContext = null;
  }
}

/// Represents how the app was launched
class LaunchContext {
  final LaunchType type;
  final Map<String, dynamic> data;

  LaunchContext({
    required this.type,
    required this.data,
  });
}

/// Types of app launches
enum LaunchType {
  normal,
  pushNotification,
  deepLink,
}

/// Possible startup routes
enum StartupRoute {
  splash,
  getStarted,
  profileSetup,
  locationPermission,
  home,
}
