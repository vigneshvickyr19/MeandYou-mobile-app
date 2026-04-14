import 'package:flutter/material.dart';
import '../constants/firebase_constants.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../constants/app_colors.dart';

class OnboardingService {
  OnboardingService._();
  static final OnboardingService instance = OnboardingService._();

  /// Check if a tour should be shown for the current user
  bool shouldShowTour(BuildContext context, String onboardingKey) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return false;

    switch (onboardingKey) {
      case FirebaseConstants.onboardingHome:
        return !user.onboardingHome;
      case FirebaseConstants.onboardingLikes:
        return !user.onboardingLikes;
      default:
        return false;
    }
  }

  /// Mark a tour as completed in Firebase
  Future<void> completeTour(BuildContext context, String onboardingKey) async {
    await context.read<AuthProvider>().completeOnboarding(onboardingKey);
  }

  /// Modern dark theme configuration for ShowcaseView
  static Widget buildShowcaseWrapper({
    required GlobalKey showcaseKey,
    required Widget Function(BuildContext) builder,
    VoidCallback? onFinish,
  }) {
    return ShowCaseWidget(
      key: showcaseKey,
      onFinish: onFinish,
      enableAutoScroll: true,
      blurValue: 1,
      autoPlay: false,
      autoPlayDelay: const Duration(seconds: 3),
      builder: builder,
    );
  }

  /// Custom themed Showcase widget
  static Widget themedShowcase({
    required GlobalKey key,
    required String description,
    required Widget child,
    EdgeInsets targetPadding = const EdgeInsets.all(8),
    bool isLast = false,
  }) {
    return Showcase(
      key: key,
      description: description,
      targetPadding: targetPadding,
      tooltipBackgroundColor: AppColors.surface,
      textColor: Colors.white,
      descTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      overlayColor: Colors.black.withValues(alpha: 0.8),
      blurValue: 1,
      targetBorderRadius: BorderRadius.circular(16),
      child: child,
    );
  }
}
