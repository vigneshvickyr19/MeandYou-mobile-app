import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_progress_bar.dart';

import '../widgets/step_1_basic_identity.dart';
import '../widgets/step_2_photos.dart';
import '../widgets/step_3_location.dart';
import '../widgets/step_4_about_me.dart';
import '../widgets/step_5_quick_stats.dart';
import '../widgets/step_6_lifestyle.dart';
import '../widgets/step_7_dating_preferences.dart';
import '../widgets/step_8_verification.dart';
import '../widgets/success_profile_modal.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => ProfileSetupPageState();
}

class ProfileSetupPageState extends State<ProfileSetupPage> {
  int _currentStep = 0;
  static const int totalSteps = 8;

  late final List<Widget> _steps = [
    StepBasicIdentity(),
    StepPhotos(),
    StepLocation(),
    StepAboutMe(),
    StepQuickStats(),
    StepLifestyle(),
    StepDatingPreferences(),
    StepVerification(),
  ];

  /// NEXT BUTTON HANDLER
  void _next() {
    if (_currentStep < totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      SuccessProfileModal.show(context);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentStep + 1) / totalSteps;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// ───────────────── TOP BAR ─────────────────
              Row(
                children: [
                  /// BACK BUTTON
                  GestureDetector(
                    onTap: _back,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// PROGRESS BAR
                  Expanded(child: AppProgressBar(progress: progress)),
                ],
              ),

              const SizedBox(height: 28),

              /// ───────────────── STEP CONTENT ─────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _steps[_currentStep],
                ),
              ),

              const SizedBox(height: 20),

              /// ───────────────── CONTINUE BUTTON ─────────────────
              AppButton(
                text: _currentStep == totalSteps - 1 ? 'Finish' : 'Continue',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
