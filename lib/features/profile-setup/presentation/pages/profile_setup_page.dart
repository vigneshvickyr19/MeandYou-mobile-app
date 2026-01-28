import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_setup_provider.dart';
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

import '../controllers/profile_setup_controller.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  static final List<Widget> _steps = [
    const StepBasicIdentity(),
    const StepPhotos(),
    const StepLocation(),
    const StepAboutMe(),
    const StepQuickStats(),
    const StepLifestyle(),
    const StepDatingPreferences(),
    const StepVerification(),
  ];

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Initialize once if needed
    if (profileProvider.draftProfile == null && authProvider.currentUser != null) {
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// TOP BAR
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.handleBack(context),
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
                        Expanded(child: AppProgressBar(progress: profileProvider.progress)),
                      ],
                    ),
  
                    const SizedBox(height: 28),
  
                    /// STEP CONTENT
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _steps[profileProvider.currentStep],
                      ),
                    ),
  
                    const SizedBox(height: 20),
  
                    /// CONTINUE BUTTON
                    AppButton(
                      text: profileProvider.currentStep == 7 ? 'Finish' : 'Continue',
                      isLoading: profileProvider.isSaving,
                      onPressed: () => controller.handleContinue(context),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
