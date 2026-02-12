import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/success_profile_modal.dart';

class ProfileSetupController {
  final ProfileSetupProvider provider;
  final AuthProvider authProvider;

  ProfileSetupController({required this.provider, required this.authProvider});

  Future<void> handleContinue(BuildContext context) async {
    // 1. Validate Current Step
    if (!provider.validateCurrentStep()) {
      // Errors are now shown in-line under widgets
      return;
    }

    if (provider.currentStep < 7) {
      provider.nextStep();
    } else {
      // Final Step
      try {
        if (authProvider.currentUser == null) throw "User not authenticated";

        await provider.completeProfile(authProvider.currentUser!);

        if (context.mounted) {
          await SuccessProfileModal.show(context);
        }

        // Final locally update
        final updatedUser = authProvider.currentUser!.copyWith(
          isProfileComplete: true,
        );
        authProvider.updateUserLocally(updatedUser);
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.show(
            context,
            message: "Failed to save profile: $e",
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  void handleBack(BuildContext context) {
    if (provider.currentStep > 0) {
      provider.prevStep();
    } else {
      authProvider.signOut();
    }
  }
}
