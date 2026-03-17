import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  final TextEditingController phoneController = TextEditingController();
  
  String _fullPhoneNumber = '';
  bool _showPhoneError = false;
  bool _isButtonEnabled = false;

  LoginController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get showPhoneError => _showPhoneError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;

  set phoneNumber(String value) => _fullPhoneNumber = value;

  void validateInputs() {
    final phone = phoneController.text.trim();
    
    // Basic phone validation
    final isPhoneValid = phone.length >= 8;
    
    _isButtonEnabled = isPhoneValid;
    _showPhoneError = phone.isNotEmpty && !isPhoneValid;
    
    notifyListeners();
  }

  Future<void> sendOtp(BuildContext context) async {
    if (!_isButtonEnabled) {
      validateInputs();
      return;
    }

    try {
      await _authProvider.loginWithPhone(
        _fullPhoneNumber,
        (verificationId, resendToken) {
          if (context.mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyCode,
              arguments: {
                'phoneNumber': _fullPhoneNumber,
                'verificationId': verificationId,
              },
            );
          }
        },
        onError: (error) {
          if (context.mounted) {
            AppSnackbar.show(
              context,
              message: error,
              type: SnackbarType.error,
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: e.toString(),
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    phoneController.dispose();
    super.dispose();
  }
}
