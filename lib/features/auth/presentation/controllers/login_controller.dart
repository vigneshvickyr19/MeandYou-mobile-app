import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';

class LoginController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _isButtonEnabled = false;

  LoginController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showEmailError => _showEmailError;
  bool get showPasswordError => _showPasswordError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;

  void validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    _showEmailError = email.isNotEmpty && !emailRegex.hasMatch(email);
    _showPasswordError = password.isNotEmpty && password.length < 6;
    _isButtonEnabled = emailRegex.hasMatch(email) && password.length >= 6;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (!_isButtonEnabled) {
      validateInputs();
      AppSnackbar.show(
        context,
        message: "Please fix the errors before continuing",
        type: SnackbarType.error,
      );
      return;
    }

    try {
      await _authProvider.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Login successful",
          type: SnackbarType.success,
        );
        Navigator.of(context).pop(); // Back to AuthWrapper which will show Home
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: e.toString().contains('user-not-found')
              ? "User not found"
              : e.toString().contains('wrong-password')
                  ? "Incorrect password"
                  : "Login failed: $e",
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
