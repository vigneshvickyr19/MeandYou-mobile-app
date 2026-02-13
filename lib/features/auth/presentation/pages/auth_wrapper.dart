import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/startup_provider.dart';
import '../../../auth/presentation/pages/get_started_page.dart';
import '../../../home/presentation/pages/home_shell_page.dart';
import '../../../profile-setup/presentation/pages/profile_setup_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../matching/presentation/pages/location_permission_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Combine all necessary states into a single selector for efficient rebuilding
    return Selector3<StartupProvider, AuthProvider, LocationProvider, _AppState>(
      selector: (context, startup, auth, loc) => _AppState(
        isSplashDone: startup.isSplashDone,
        isNotificationLaunch: startup.isNotificationLaunch,
        isAuthInitializing: auth.isInitializing,
        isAuthenticated: auth.isAuthenticated,
        isProfileComplete: auth.currentUser?.isProfileComplete ?? false,
        geohash: auth.currentUser?.geohash,
        isLocationChecking: loc.isChecking,
        hasLocationAccess: loc.hasEffectiveLocation,
      ),
      builder: (context, state, _) {
        // 1. Splash Screen Phase
        // Normal Launch: Show Splash until BOTH timer is done AND auth is initialized.
        // This prevents the "Splash -> Loading Spinner -> Home" transition.
        bool showSplash = !state.isSplashDone;
        if (!state.isNotificationLaunch && state.isAuthInitializing) {
          showSplash = true;
        }

        if (showSplash && !state.isNotificationLaunch) {
          return const SplashPage();
        }

        // 2. Auth Initialization Phase
        // Only hit this if:
        // a) Notification launch AND auth initializing (Black loader)
        // b) Normal launch (should be covered by splash above, but safety fallback)
        if (state.isAuthInitializing) {
           return const Scaffold(
             backgroundColor: Colors.black,
             body: Center(child: CircularProgressIndicator()),
           );
        }

        // 3. Authentication Check
        if (!state.isAuthenticated) {
          return const GetStartedPage();
        }

        // 4. Profile Completion Check
        if (!state.isProfileComplete) {
          return const ProfileSetupPage();
        }

        // 5. Notification Launch Check
        // If launched via notification, we skip location checks to unblock navigation
        if (state.isNotificationLaunch) {
          return const HomeShellPage();
        }

        // 6. Final Access Check
        // Check this BEFORE isLocationChecking.
        // If we already have access, we stay on HomeShellPage even if a background check runs.
        final hasLocationData = state.geohash != null && state.geohash!.isNotEmpty;
        
        if (state.hasLocationAccess && hasLocationData) {
          return const HomeShellPage();
        }

        // 7. Location & Permission Phase
        // Only show loading if we don't have access yet and are checking
        if (state.isLocationChecking) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 8. Location Permission Gate
        // Stability: Always return the same widget instance with a key to prevent remounts
        return const LocationPermissionPage(
          key: ValueKey('location_permission_gate'),
        );
      },
    );
  }
}

class _AppState {
  final bool isSplashDone;
  final bool isNotificationLaunch;
  final bool isAuthInitializing;
  final bool isAuthenticated;
  final bool isProfileComplete;
  final String? geohash;
  final bool isLocationChecking;
  final bool hasLocationAccess;

  _AppState({
    required this.isSplashDone,
    required this.isNotificationLaunch,
    required this.isAuthInitializing,
    required this.isAuthenticated,
    required this.isProfileComplete,
    this.geohash,
    required this.isLocationChecking,
    required this.hasLocationAccess,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AppState &&
          runtimeType == other.runtimeType &&
          isSplashDone == other.isSplashDone &&
          isNotificationLaunch == other.isNotificationLaunch &&
          isAuthInitializing == other.isAuthInitializing &&
          isAuthenticated == other.isAuthenticated &&
          isProfileComplete == other.isProfileComplete &&
          geohash == other.geohash &&
          isLocationChecking == other.isLocationChecking &&
          hasLocationAccess == other.hasLocationAccess;

  @override
  int get hashCode =>
      isSplashDone.hashCode ^
      isNotificationLaunch.hashCode ^
      isAuthInitializing.hashCode ^
      isAuthenticated.hashCode ^
      isProfileComplete.hashCode ^
      geohash.hashCode ^
      isLocationChecking.hashCode ^
      hasLocationAccess.hashCode;
}
