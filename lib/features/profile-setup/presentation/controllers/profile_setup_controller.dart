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
    if (!provider.isStepValid(provider.currentStep)) {
      String errorMsg = _getStepErrorMessage(provider.currentStep);
      AppSnackbar.show(context, message: errorMsg, type: SnackbarType.error);
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

  String _getStepErrorMessage(int step) {
    final p = provider.draftProfile;
    if (p == null) return "Profile initialization error.";

    switch (step) {
      case 0:
        if (p.fullName == null || p.fullName!.isEmpty) {
          return "Please enter your Full Name.";
        }
        if (p.dob == null) return "Please select your Date of Birth.";
        if (p.gender == null) return "Please select your Gender.";
        return "Please complete all fields.";
      case 1:
        if (p.photos == null || p.photos!.isEmpty) {
          return "Please upload at least one photo.";
        }
        return "Please upload photos.";
      case 2:
        if (p.addressLine1 == null || p.addressLine1!.isEmpty) {
          return "Please enter Address Line 1.";
        }
        if (p.city == null || p.city!.isEmpty) return "Please enter City.";
        if (p.state == null || p.state!.isEmpty) return "Please enter State.";
        if (p.country == null || p.country!.isEmpty) {
          return "Please enter Country.";
        }
        if (p.pinCode == null || p.pinCode!.isEmpty) {
          return "Please enter Pin Code.";
        }
        return "Please complete address details.";
      case 3:
        if (p.bio == null || p.bio!.isEmpty) return "Please enter your Bio.";
        return "Please enter your Bio.";
      case 4:
        if (p.height == null) return "Please select Height.";
        if (p.jobTitle == null) return "Please enter Job Title.";
        if (p.education == null) return "Please select Education.";
        if (p.hometown == null) return "Please enter Hometown.";
        return "Please complete quick stats.";
      case 5:
        if (p.drinking == null) return "Please select Drinking habit.";
        if (p.smoking == null) return "Please select Smoking habit.";
        if (p.exercise == null) return "Please select Exercise habit.";
        if (p.diet == null) return "Please select Diet.";
        if (p.pets == null) return "Please select Pets.";
        if (p.religion == null) return "Please select Religion.";
        if (p.language == null) return "Please select Language.";
        return "Please complete lifestyle details.";
      case 6:
        if (p.lookingFor == null) {
          return "Please select what you are looking for.";
        }
        if (p.minAge == null || p.maxAge == null) {
          return "Please select Age Range.";
        }
        if (p.distance == null) return "Please select Distance preference.";
        if (p.interests == null || p.interests!.isEmpty) {
          return "Please select at least one Interest.";
        }
        return "Please complete preferences.";
      default:
        return "Please fill in all required fields to proceed.";
    }
  }
}
