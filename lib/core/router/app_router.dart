import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/get_started_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/profile-setup/presentation/pages/profile_setup_page.dart';
import '../../features/chat/presentation/pages/chat_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/matching/presentation/pages/location_permission_page.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../../features/auth/presentation/pages/auth_wrapper.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_analysis_page.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.authWrapper: (_) => const AuthWrapper(),
    AppRoutes.getStarted: (_) => const GetStartedPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.verifyCode: (_) => const VerifyCodePage(),
    AppRoutes.profileSetupPage: (_) => const ProfileSetupPage(),
    AppRoutes.home: (_) => const HomeShellPage(),
    AppRoutes.chat: (_) => const HomeShellPage(initialTabIndex: 2),
    AppRoutes.profile: (_) => const HomeShellPage(initialTabIndex: 3),
    AppRoutes.likes: (_) => const HomeShellPage(initialTabIndex: 1),
    AppRoutes.locationPermission: (_) => const LocationPermissionPage(),
  };

  // Generate route with support for deep linking parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeShellPage(
            initialTabIndex: args?['tabIndex'] as int?,
            initialSubTabIndex: args?['subTabIndex'] as int?,
          ),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => HomeShellPage(initialTabIndex: 3),
          settings: settings,
        );

      case AppRoutes.otherProfile:
        final userId = args?['userId'] as String?;
        return MaterialPageRoute(
          builder: (_) => ProfilePage(
            key: ValueKey(userId ?? 'own_profile'),
            userId: userId,
          ),
          settings: settings,
        );

      case AppRoutes.chat:
        return MaterialPageRoute(
          builder: (_) => HomeShellPage(initialTabIndex: 2),
          settings: settings,
        );

      case AppRoutes.chatDetail:
        final chatRoomId = args?['chatRoomId'] as String?;
        final otherUser = args?['otherUser'] as UserModel?;
        if (chatRoomId != null && otherUser != null) {
          return MaterialPageRoute(
            builder: (_) =>
                ChatDetailPage(chatRoomId: chatRoomId, otherUser: otherUser),
            settings: settings,
          );
        }
        return null;

      case AppRoutes.likes:
        return MaterialPageRoute(
          builder: (_) => HomeShellPage(initialTabIndex: 1),
          settings: settings,
        );

      case AppRoutes.authWrapper:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
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

      case AppRoutes.verifyCode:
        return MaterialPageRoute(
          builder: (_) => const VerifyCodePage(),
          settings: settings,
        );

      case AppRoutes.profileSetupPage:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupPage(),
          settings: settings,
        );

      case AppRoutes.locationPermission:
        return MaterialPageRoute(
          builder: (_) => const LocationPermissionPage(),
          settings: settings,
        );
      
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );
      
      case AppRoutes.profileAnalysis:
        final profile = args?['profile'];
        if (profile is ProfileModel) {
          return MaterialPageRoute(
            builder: (_) => ProfileAnalysisPage(profile: profile),
            settings: settings,
          );
        }
        return null;

      default:
        return null;
    }
  }
}
