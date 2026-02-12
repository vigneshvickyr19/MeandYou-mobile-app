import 'package:flutter/material.dart';
import '../widgets/splash_content.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SplashContent(),
    );
  }
}
