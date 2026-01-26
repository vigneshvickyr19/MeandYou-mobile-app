import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';

class SplashController {
  static void navigateToHome(BuildContext context) {
    Timer(const Duration(milliseconds: 2200), () {
      // Check if the widget is still mounted and context is valid
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
      }
    });
  }
}
