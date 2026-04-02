import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/services/startup_service.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../auth/presentation/pages/get_started_page.dart';
import '../../../profile-setup/presentation/pages/profile_setup_page.dart';
import '../../../matching/presentation/pages/location_permission_page.dart';
import '../../../home/presentation/pages/home_shell_page.dart';

/// Clean, declarative auth wrapper
/// No business logic - purely presentational
/// All routing decisions are made by AppStateProvider
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        // Show splash screen during initialization
        if (appState.shouldShowSplash) {
          return const SplashPage();
        }

        // Show loading indicator during auth initialization
        // Only for normal launches - special launches skip this
        if (appState.isAuthInitializing && 
            appState.launchContext?.type == LaunchType.normal) {
          return const _LoadingScreen();
        }

        // Show loading during location check (only if not already on home)
        if (appState.isLocationChecking && 
            appState.targetRoute != StartupRoute.home &&
            appState.launchContext?.type == LaunchType.normal) {
          return const _LoadingScreen();
        }

        // Navigate based on target route
        return _buildTargetScreen(appState.targetRoute);
      },
    );
  }

  Widget _buildTargetScreen(StartupRoute route) {
    switch (route) {
      case StartupRoute.splash:
        return const SplashPage();
      
      case StartupRoute.getStarted:
        return const GetStartedPage();
      
      case StartupRoute.profileSetup:
        return const ProfileSetupPage();
      
      case StartupRoute.locationPermission:
        return const LocationPermissionPage(
          key: ValueKey('location_permission_gate'),
        );
      
      case StartupRoute.home:
        return const HomeShellPage();
    }
  }
}

/// Consistent loading screen to prevent flashes
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
