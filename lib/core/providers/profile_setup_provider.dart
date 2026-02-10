import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../../data/repositories/user_repository.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

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
        return p.fullName != null &&
            p.fullName!.isNotEmpty &&
            p.dob != null &&
            p.gender != null;
      case 1: // Step 2: Photos
        return p.photos != null && p.photos!.isNotEmpty;
      case 2: // Step 3: Address
        return p.addressLine1 != null &&
            p.addressLine1!.isNotEmpty &&
            p.city != null &&
            p.city!.isNotEmpty &&
            p.state != null &&
            p.state!.isNotEmpty &&
            p.country != null &&
            p.country!.isNotEmpty &&
            p.pinCode != null &&
            p.pinCode!.isNotEmpty;
      case 3: // Step 4: Bio
        return p.bio != null && p.bio!.isNotEmpty;
      case 4: // Step 5: Quick Stats
        return p.height != null &&
            p.jobTitle != null &&
            p.education != null &&
            p.hometown != null;
      case 5: // Step 6: Lifestyle
        return p.drinking != null &&
            p.smoking != null &&
            p.exercise != null &&
            p.diet != null &&
            p.pets != null &&
            p.religion != null &&
            p.language != null;
      case 6: // Step 7: Preferences & Interests
        return p.lookingFor != null &&
            p.minAge != null &&
            p.maxAge != null &&
            p.distance != null &&
            p.interests != null &&
            p.interests!.isNotEmpty;
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
      // 1. Upload photos if they are local paths
      List<String> uploadedUrls = [];
      if (_draftProfile!.photos != null) {
        for (int i = 0; i < _draftProfile!.photos!.length; i++) {
          String photo = _draftProfile!.photos![i];
          if (photo.isEmpty) continue;
          
          if (photo.startsWith('http')) {
            uploadedUrls.add(photo);
          } else {
            // It's a local path from StepPhotos
            final url = await StorageService.instance.uploadProfileImage(
              userId: currentUser.id,
              file: File(photo),
              index: i,
            );
            uploadedUrls.add(url);
          }
        }
      }

      // 2. Update draft with download URLs
      _draftProfile = _draftProfile!.copyWith(photos: uploadedUrls);

      // 3. Save Profile Setup data
      await _userRepository.saveProfileSetup(_draftProfile!);

      // 2. Update User Account status & sync core details
      final String? fcmToken = NotificationService.instance.fcmToken;
      UserModel updatedUser = currentUser.copyWith(
        fullName: _draftProfile!.fullName,
        profileImageUrl: _draftProfile!.photos?.isNotEmpty == true
            ? _draftProfile!.photos!.first
            : null,
        isProfileComplete: true,
        fcmToken: fcmToken,
      );
      await _userRepository.updateUserAccount(updatedUser);

      // Also ensure FCM token is saved separately if available
      if (fcmToken != null) {
        await _userRepository.updateFcmToken(currentUser.id, fcmToken);
      }

      // Also ensure VoIP token is saved separately for iOS if available
      final String? voipToken = await NotificationService.instance
          .getVoIPToken();
      if (voipToken != null) {
        await _userRepository.updateVoipToken(currentUser.id, voipToken);
      }
    } catch (e) {
      debugPrint("Error completing profile: $e");
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
