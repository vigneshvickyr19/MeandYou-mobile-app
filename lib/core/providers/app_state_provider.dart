import 'dart:async';
import 'package:flutter/material.dart';
import '../services/startup_service.dart';
import 'auth_provider.dart';
import 'location_provider.dart';
import '../services/deep_link_service.dart';

/// Centralized provider that manages the overall app state
/// Coordinates between auth, location, and startup services
/// Provides a single source of truth for navigation decisions
class AppStateProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final LocationProvider _locationProvider;
  final StartupService _startupService = StartupService.instance;

  // Splash timer
  Timer? _splashTimer;
  bool _isSplashTimerComplete = false;

  AppStateProvider({
    required AuthProvider authProvider,
    required LocationProvider locationProvider,
  })  : _authProvider = authProvider,
        _locationProvider = locationProvider {
    _initialize();
  }

  // Getters for current state
  bool get isAuthenticated => _authProvider.isAuthenticated;
  bool get isAuthInitializing => _authProvider.isInitializing;
  bool get isProfileComplete => _authProvider.currentUser?.isProfileComplete ?? false;
  bool get hasGeohash => _authProvider.currentUser?.geohash != null && 
                         _authProvider.currentUser!.geohash!.isNotEmpty;
  bool get hasLocationAccess => _locationProvider.hasEffectiveLocation;
  bool get isLocationChecking => _locationProvider.isChecking;
  
  // Splash state
  bool get shouldShowSplash {
    // Keep splash visible until both branding timer is done AND critical services are ready
    if (!_isSplashTimerComplete) return true;
    if (isAuthInitializing || isLocationChecking) return true;
    return false;
  }
  
  // Launch context exposed for UI (e.g. AuthWrapper to decide on loading spinners)
  LaunchContext? get launchContext => _startupService.launchContext;

  // Final destination route determined by business logic in StartupService
  StartupRoute get targetRoute => _startupService.determineTargetRoute(
        isAuthenticated: isAuthenticated,
        isProfileComplete: isProfileComplete,
        hasLocationAccess: hasLocationAccess,
        hasGeohash: hasGeohash,
      );

  void _initialize() {
    // Synchronize with core dependencies
    _authProvider.addListener(_onStateChanged);
    _locationProvider.addListener(_onStateChanged);

    // Ensure background services (Firebase, Notifications) are kicked off
    _ensureServicesInitialized();

    // Enforce branding splash duration
    _startSplashTimer();
  }

  /// Coordinates background initialization and notifies deep link service when ready
  Future<void> _ensureServicesInitialized() async {
    if (!_startupService.isInitialized) {
      await _startupService.initialize();
      notifyListeners();
      
      // Attempt to resolve any pending deep links now that launch context is known
      DeepLinkService().checkPendingNavigation();
    }
  }

  void _startSplashTimer() {
    _splashTimer = Timer(const Duration(milliseconds: 1500), () {
      debugPrint('AppStateProvider: Branding splash complete, transitioning...');
      _isSplashTimerComplete = true;
      _startupService.completeSplash();
      
      // Notify listeners first to trigger AuthWrapper rebuild (Splash -> Home)
      notifyListeners();
      
      // Crucial: Wait for the frame to settle so HomeShellPage is mounted
      // before attempting to push detail screens on top of it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('AppStateProvider: UI settled, checking for pending notifications');
        // Signal that UI is ready (if not already) and check for pending navigation
        DeepLinkService().setUiReady(true);
        DeepLinkService().checkPendingNavigation();
      });
    });
  }

  void _onStateChanged() => notifyListeners();

  @override
  void dispose() {
    _splashTimer?.cancel();
    _authProvider.removeListener(_onStateChanged);
    _locationProvider.removeListener(_onStateChanged);
    super.dispose();
  }
}
