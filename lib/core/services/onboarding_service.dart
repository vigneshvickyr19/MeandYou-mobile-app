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
    required Widget child,
    VoidCallback? onFinish,
  }) {
    return _ShowcaseRegistrationWrapper(
      onFinish: onFinish,
      child: child,
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

class _ShowcaseRegistrationWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFinish;

  const _ShowcaseRegistrationWrapper({
    required this.child,
    this.onFinish,
  });

  @override
  State<_ShowcaseRegistrationWrapper> createState() => _ShowcaseRegistrationWrapperState();
}

class _ShowcaseRegistrationWrapperState extends State<_ShowcaseRegistrationWrapper> {
  @override
  void initState() {
    super.initState();
    // Use factory constructor to initialize showcase settings
    // This sets up the singleton for this lifecycle
    ShowcaseView.register(
      onFinish: widget.onFinish,
      enableAutoScroll: true,
      blurValue: 1,
      autoPlay: false,
      autoPlayDelay: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    // Clean up using the singleton getter
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
