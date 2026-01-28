import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../../data/repositories/user_repository.dart';

class ProfileSetupProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  
  ProfileModel? _draftProfile;
  bool _isSaving = false;
  int _currentStep = 0;
  static const int totalSteps = 8;

  ProfileModel? get draftProfile => _draftProfile;
  bool get isSaving => _isSaving;
  int get currentStep => _currentStep;
  double get progress => (_currentStep + 1) / totalSteps;

  void initialize(String userId) {
    _draftProfile = ProfileModel(userId: userId);
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Update logic for individual fields
  void updateProfile(ProfileModel Function(ProfileModel) updateFn) {
    if (_draftProfile != null) {
      _draftProfile = updateFn(_draftProfile!);
      notifyListeners();
    }
  }

  // Validation for each step
  bool isStepValid(int step) {
    if (_draftProfile == null) return false;
    final p = _draftProfile!;

    switch (step) {
      case 0: // Step 1: Basic Identity
        return p.fullName != null && p.fullName!.isNotEmpty && p.dob != null && p.gender != null;
      case 1: // Step 2: Photos
        return p.photos != null && p.photos!.isNotEmpty;
      case 2: // Step 3: Address
        return p.addressLine1 != null && p.addressLine1!.isNotEmpty &&
               p.city != null && p.city!.isNotEmpty &&
               p.state != null && p.state!.isNotEmpty &&
               p.country != null && p.country!.isNotEmpty &&
               p.pinCode != null && p.pinCode!.isNotEmpty;
      case 3: // Step 4: Bio
        return p.bio != null && p.bio!.isNotEmpty;
      case 4: // Step 5: Quick Stats
        return p.height != null && p.jobTitle != null && p.education != null && p.hometown != null;
      case 5: // Step 6: Lifestyle
        return p.drinking != null && p.smoking != null && p.exercise != null && 
               p.diet != null && p.pets != null && p.religion != null && p.language != null;
      case 6: // Step 7: Preferences & Interests
        return p.lookingFor != null && p.minAge != null && p.maxAge != null && 
               p.distance != null && p.interests != null && p.interests!.isNotEmpty;
      case 7: // Step 8: Verification & Socials
        // Basic check for socials if needed, but the user said "only if click step 8 finally save"
        return true; 
      default:
        return false;
    }
  }

  // Final Save to Database
  Future<void> completeProfile(UserModel currentUser) async {
    if (_draftProfile == null) return;
    
    _isSaving = true;
    notifyListeners();

    try {
      // 1. Save Profile Setup data
      await _userRepository.saveProfileSetup(_draftProfile!);
      
      // 2. Update User Account status
      UserModel updatedUser = currentUser.copyWith(
        isProfileComplete: true,
      );
      await _userRepository.updateUserAccount(updatedUser);
      
    } catch (e) {
      debugPrint("Error completing profile: $e");
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
