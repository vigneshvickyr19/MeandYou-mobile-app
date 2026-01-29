import 'package:flutter/material.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final AuthProvider _authProvider;
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileController(this._authProvider);

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String? userId) async {
    final targetUserId = userId ?? _authProvider.currentUser?.id;
    if (targetUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile(targetUserId);
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authProvider.signOut();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  // Helper to calculate age from DOB
  int? get age {
    if (_profile?.dob == null) return null;
    final now = DateTime.now();
    int age = now.year - _profile!.dob!.year;
    if (now.month < _profile!.dob!.month ||
        (now.month == _profile!.dob!.month && now.day < _profile!.dob!.day)) {
      age--;
    }
    return age;
  }
}
