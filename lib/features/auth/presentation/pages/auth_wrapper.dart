import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/pages/get_started_page.dart';
import '../../../home/presentation/pages/home_shell_page.dart';

import '../../../splash/presentation/pages/splash_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 1. Show Splash only during the very first Firebase check
        if (authProvider.isInitializing) {
          return const SplashPage();
        }

        final user = authProvider.currentUser;

        // 2. If no user, go to onboarding
        if (user == null) {
          return const GetStartedPage();
        }

        // 3. User detected - go to Home immediately
        // Note: fetchFullProfile was already triggered in AuthProvider._init
        // HomeShellPage will handle the "Profile Incomplete" overlay if needed
        return const HomeShellPage();
      },
    );
  }
}
