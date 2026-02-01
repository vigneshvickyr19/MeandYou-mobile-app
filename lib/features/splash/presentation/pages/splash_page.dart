import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/splash_content.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start the timer
    final timerFuture = Future.delayed(const Duration(milliseconds: 2200));

    // Wait for auth initialization if possible
    // We don't want to block forever, so we can use a timeout or just wait
    // Since AuthProvider starts initializing on app start, it should be ready soon.
    
    // We use context.read because we don't need to listen here
    final authProvider = context.read<AuthProvider>();
    
    // Function to wait for isInitializing to become false with a max timeout
    Future<void> waitForAuth() async {
      int attempts = 0;
      const maxAttempts = 50; // 5 seconds (50 * 100ms)
      while (authProvider.isInitializing && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    await Future.wait([timerFuture, waitForAuth()]);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.authWrapper);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: SplashContent(),
    );
  }
}
