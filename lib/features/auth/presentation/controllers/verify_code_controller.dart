import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/email_otp_service.dart';
import '../../../../core/constants/app_routes.dart';

class VerifyCodeController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController codeController = TextEditingController();
  bool _showError = false;
  bool _isButtonEnabled = false;
  bool _isLocalLoading = false;

  VerifyCodeController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showError => _showError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _isLocalLoading || _authProvider.isLoading;

  void validateCode(String value) {
    _isButtonEnabled = value.trim().length == 6;
    _showError = value.isNotEmpty && !_isButtonEnabled;
    notifyListeners();
  }

  Future<void> verify(BuildContext context, String email) async {
    final code = codeController.text.trim();
    if (!_isButtonEnabled) {
      _showError = true;
      notifyListeners();
      AppSnackbar.show(
        context,
        message: "Please enter a valid 6-digit code",
        type: SnackbarType.error,
      );
      return;
    }

    _isLocalLoading = true;
    notifyListeners();

    try {
      bool isValid = EmailOtpService.verifyOtp(email, code);
      if (isValid) {
        if (context.mounted) {
          Navigator.pushNamed(
            context, 
            AppRoutes.createPassword,
            arguments: {'email': email},
          );
        }
      } else {
        _showError = true;
        if (context.mounted) {
          AppSnackbar.show(
            context, 
            message: "Incorrect code. Please check your email.", 
            type: SnackbarType.error
          );
        }
      }
    } finally {
      _isLocalLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    codeController.dispose();
    super.dispose();
  }
}
