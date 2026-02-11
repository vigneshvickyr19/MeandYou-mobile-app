import 'package:flutter/material.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final AuthProvider _authProvider;
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? _profile;
  UserModel? _user;
  bool _isLoading = false;

  ProfileController(this._authProvider);

  ProfileModel? get profile => _profile;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String? userId) async {
    final targetUserId = userId ?? _authProvider.currentUser?.id;
    if (targetUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _profileRepository.getProfile(targetUserId),
        _profileRepository.getUser(targetUserId),
      ]);
      _profile = results[0] as ProfileModel?;
      _user = results[1] as UserModel?;
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
  int? get age => _profile?.age;
}
