import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/splash_content.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: SplashContent(),
    );
  }
}
