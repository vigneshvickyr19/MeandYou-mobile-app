import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/email_otp_service.dart';
import '../../../../core/constants/app_routes.dart';

class SignUpController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController emailController = TextEditingController();
  bool _showError = false;
  bool _isButtonEnabled = false;
  bool _isLocalLoading = false;

  SignUpController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showError => _showError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _isLocalLoading || _authProvider.isLoading;

  void validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    _isButtonEnabled = emailRegex.hasMatch(value);
    _showError = value.isNotEmpty && !_isButtonEnabled;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    final email = emailController.text.trim();

    if (!_isButtonEnabled) {
      _showError = true;
      notifyListeners();
      AppSnackbar.show(
        context,
        message: "Please enter a valid email",
        type: SnackbarType.error,
      );
      return;
    }

    _isLocalLoading = true;
    notifyListeners();
    
    try {
      // Send OTP (Mock)
      await EmailOtpService.sendOtp(email);

      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "OTP sent to your email!",
          type: SnackbarType.success,
        );

        // Navigate to Verify Code page
        Navigator.pushNamed(
          context, 
          AppRoutes.verifyCode, 
          arguments: {'email': email},
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Failed to send OTP. Please try again.",
          type: SnackbarType.error,
        );
      }
    } finally {
      _isLocalLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    emailController.dispose();
    super.dispose();
  }
}
