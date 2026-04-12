import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../widgets/step_1_basic_identity.dart';
import '../widgets/step_2_photos.dart';
import '../widgets/step_3_location.dart';
import '../widgets/step_4_quick_stats.dart';
import '../widgets/step_5_lifestyle.dart';
import '../widgets/step_6_dating_preferences.dart';
import '../widgets/step_7_about_me.dart';
import '../widgets/step_8_verification.dart';

import '../controllers/profile_setup_controller.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  static final List<Widget> _steps = [
    const StepBasicIdentity(),
    const StepPhotos(),
    const StepLocation(),
    const StepQuickStats(),
    const StepLifestyle(),
    const StepDatingPreferences(),
    const StepAboutMe(),
    const StepVerification(),
  ];

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Initialize once if needed
    if (profileProvider.draftProfile == null &&
        authProvider.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileProvider.initialize(authProvider.currentUser!.id);
      });
    }

    final controller = ProfileSetupController(
      provider: profileProvider,
      authProvider: authProvider,
    );

    bool isAppLoading = authProvider.isLoading || profileProvider.isSaving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.handleBack(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: isAppLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Stack(
                children: [
                  // Background Glow
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP BAR
                          Row(
                            children: [
                              AppBackButton(
                                onTap: () => controller.handleBack(context),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppProgressBar(
                                  progress: profileProvider.progress,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${(profileProvider.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          /// STEP CONTENT
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      ...previousChildren,
                                      if (currentChild != null) ...[ currentChild],
                                    ],
                                  ),
                                );
                              },
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(profileProvider.currentStep),
                                child: _steps[profileProvider.currentStep],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// CONTINUE BUTTON
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: AppButton(
                              text: profileProvider.currentStep == 7
                                  ? 'Finish Registration (8/8)'
                                  : 'Continue (${profileProvider.currentStep + 1}/8)',
                              isLoading: profileProvider.isSaving,
                              onPressed: () =>
                                  controller.handleContinue(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
