import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/get_started_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgotPassword_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/auth/presentation/pages/verify_code_page.dart';
import 'features/auth/presentation/pages/create_password_page.dart';
import 'features/home/presentation/pages/home_shell_page.dart';
import 'features/profile-setup/presentation/pages/profile_setup_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      theme: AppTheme.darkTheme,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.getStarted: (_) => const GetStartedPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.signUp: (_) => const SignUpPage(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.verifyCode: (_) => const VerifyCodePage(),
        AppRoutes.createPassword: (_) => const CreatePasswordPage(),
        AppRoutes.profileSetupPage: (_) => const ProfileSetupPage(),

        AppRoutes.home: (_) => const HomeShellPage(),
      },
    );
  }
}
