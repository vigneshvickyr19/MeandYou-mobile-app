import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/pages/get_started_page.dart';
import '../../../home/presentation/pages/home_shell_page.dart';
import '../../../profile-setup/presentation/pages/profile_setup_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (authProvider.isLoading || authProvider.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user == null) {
          return const GetStartedPage();
        }

        // Logic to check if profile is complete
        if (!user.isProfileComplete) {
          return const ProfileSetupPage();
        }

        return const HomeShellPage();
      },
    );
  }
}
