import 'dart:io';

import 'package:flutter/material.dart';
import 'package:me_and_you/features/chat/presentation/pages/chat_page.dart';
import 'package:me_and_you/features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/get_started_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgotPassword_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/create_password_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/profile-setup/presentation/pages/profile_setup_page.dart';
import '../../features/linkes/presentation/pages/like_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.getStarted: (_) => const GetStartedPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.signUp: (_) => const SignUpPage(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.verifyCode: (_) => const VerifyCodePage(),
        AppRoutes.createPassword: (_) => const CreatePasswordPage(),
        AppRoutes.profileSetupPage: (_) => const ProfileSetupPage(),
        AppRoutes.home: (_) => const HomeShellPage(),
        AppRoutes.chat: (_) => const ChatPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.likes: (_) => const LikePage(),
      };

  // Generate route with support for deep linking parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeShellPage(
            initialTabIndex: args?['tabIndex'] as int?,
          ),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => ProfilePage(
            userId: args?['userId'] as String?,
          ),
          settings: settings,
        );

      case AppRoutes.chat:
        return MaterialPageRoute(
          builder: (_) => ChatPage(
            chatId: args?['chatId'] as String?,
          ),
          settings: settings,
        );

      case AppRoutes.likes:
        return MaterialPageRoute(
          builder: (_) => const LikePage(),
          settings: settings,
        );

      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case AppRoutes.getStarted:
        return MaterialPageRoute(
          builder: (_) => const GetStartedPage(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );

      case AppRoutes.verifyCode:
        return MaterialPageRoute(
          builder: (_) => const VerifyCodePage(),
          settings: settings,
        );

      case AppRoutes.createPassword:
        return MaterialPageRoute(
          builder: (_) => const CreatePasswordPage(),
          settings: settings,
        );

      case AppRoutes.profileSetupPage:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupPage(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}

