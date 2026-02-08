import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/constants/app_routes.dart';

class VerifyCodeController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController codeController = TextEditingController();
  bool _showError = false;
  bool _isButtonEnabled = false;

  VerifyCodeController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showError => _showError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;

  void validateCode(String value) {
    // Supporting 4 or 6 digits as per requirement
    _isButtonEnabled = value.trim().length >= 4 && value.trim().length <= 6;
    _showError = value.isNotEmpty && !_isButtonEnabled;
    notifyListeners();
  }

  Future<void> verify(BuildContext context, String phoneNumber, String verificationId) async {
    final code = codeController.text.trim();
    if (!_isButtonEnabled) {
      _showError = true;
      notifyListeners();
      return;
    }

    try {
      await _authProvider.verifyOtp(
        verificationId,
        code,
      );

      if (context.mounted) {
        // Reset stack and let AuthWrapper decide (Home vs Profile Setup)
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.authWrapper,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context, 
          message: "Incorrect code. Please check and try again.", 
          type: SnackbarType.error
        );
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    codeController.dispose();
    super.dispose();
  }
}
