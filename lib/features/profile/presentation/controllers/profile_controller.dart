import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileController extends ChangeNotifier {
  final AuthProvider _authProvider;

  ProfileController(this._authProvider);

  bool get isLoading => _authProvider.isLoading;

  Future<void> logout(BuildContext context) async {
    try {
      await _authProvider.signOut();
      // AuthWrapper will handle navigation to Get Started 
      // because currentUser becomes null.
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }
}
