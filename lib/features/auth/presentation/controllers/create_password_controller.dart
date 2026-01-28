import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/constants/app_routes.dart';

class CreatePasswordController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _showError = false;
  bool _isButtonEnabled = false;

  CreatePasswordController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showError => _showError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;

  void validatePasswords() {
    final p1 = passwordController.text;
    final p2 = confirmPasswordController.text;
    _isButtonEnabled = p1.isNotEmpty && p1.length >= 6 && p1 == p2;
    _showError = p1.isNotEmpty && p2.isNotEmpty && p1 != p2;
    notifyListeners();
  }

  Future<void> submit(BuildContext context, String email) async {
    if (!_isButtonEnabled) return;

    try {
      await _authProvider.signUpWithEmail(
        email: email,
        password: passwordController.text,
      );

      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Account created successfully!",
          type: SnackbarType.success,
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.authWrapper, (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Failed to create account: $e",
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
