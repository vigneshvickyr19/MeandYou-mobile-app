import 'package:flutter/material.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../home/data/services/home_service.dart';

class ProfileController extends ChangeNotifier {
  final AuthProvider _authProvider;
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? _profile;
  UserModel? _user;
  bool _isLoading = false;
  bool _isMatched = false;

  ProfileController(this._authProvider);

  ProfileModel? get profile => _profile;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isMatched => _isMatched;

  Future<void> loadProfile(String? userId) async {
    final targetUserId = userId ?? _authProvider.currentUser?.id;
    if (targetUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _profileRepository.getProfile(targetUserId),
        _profileRepository.getUser(targetUserId),
        HomeService().checkIfMatched(_authProvider.currentUser?.id ?? '', targetUserId),
      ]);
      _profile = results[0] as ProfileModel?;
      _user = results[1] as UserModel?;
      _isMatched = results[2] as bool;
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
