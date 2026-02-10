import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/pages/get_started_page.dart';
import '../../../home/presentation/pages/home_shell_page.dart';

import '../../../profile-setup/presentation/pages/profile_setup_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../matching/presentation/pages/location_permission_page.dart';
import '../../../../core/providers/location_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initial Initialization Check
    final isInitializing = context.select<AuthProvider, bool>((p) => p.isInitializing);
    if (isInitializing) {
      return const SplashPage();
    }

    // 2. Auth State Check
    final userId = context.select<AuthProvider, String?>((p) => p.currentUser?.id);
    if (userId == null) {
      return const GetStartedPage();
    }

    // 3. Selective build based on specific state changes
    return Selector2<AuthProvider, LocationProvider, _AuthState>(
      selector: (context, auth, loc) => _AuthState(
        isProfileComplete: auth.currentUser?.isProfileComplete ?? false,
        geohash: auth.currentUser?.geohash,
        hasLocationAccess: loc.hasEffectiveLocation,
        isChecking: loc.isChecking,
      ),
      builder: (context, state, _) {
        if (!state.isProfileComplete) {
          return const ProfileSetupPage();
        }

        bool hasLocationData = state.geohash != null && state.geohash!.isNotEmpty;

        if (state.hasLocationAccess && hasLocationData) {
          return const HomeShellPage();
        }

        // Stability: Always return the same widget instance with a key to prevent remounts
        return const LocationPermissionPage(
          key: ValueKey('location_permission_gate'),
        );
      },
    );
  }
}

class _AuthState {
  final bool isProfileComplete;
  final String? geohash;
  final bool hasLocationAccess;
  final bool isChecking;

  _AuthState({
    required this.isProfileComplete,
    this.geohash,
    required this.hasLocationAccess,
    required this.isChecking,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AuthState &&
          runtimeType == other.runtimeType &&
          isProfileComplete == other.isProfileComplete &&
          geohash == other.geohash &&
          hasLocationAccess == other.hasLocationAccess &&
          isChecking == other.isChecking;

  @override
  int get hashCode =>
      isProfileComplete.hashCode ^
      geohash.hashCode ^
      hasLocationAccess.hashCode ^
      isChecking.hashCode;
}
