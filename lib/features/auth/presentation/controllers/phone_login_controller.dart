import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';

class PhoneLoginController extends ChangeNotifier {
  final AuthProvider _authProvider;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _otpSent = false;
  String? _verificationId;
  String? _phoneErrorMessage;
  String? _otpErrorMessage;
  bool _isButtonEnabled = false;

  PhoneLoginController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  bool get otpSent => _otpSent;
  String? get phoneErrorMessage => _phoneErrorMessage;
  String? get otpErrorMessage => _otpErrorMessage;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;

  void validatePhone(String value) {
    _phoneErrorMessage = null;
    _isButtonEnabled = value.trim().length >= 10;
    notifyListeners();
  }

  void validateOtp(String value) {
    _otpErrorMessage = null;
    _isButtonEnabled = value.trim().length == 6;
    notifyListeners();
  }

  Future<void> sendOtp(BuildContext context) async {
    String phone = phoneController.text.trim();

    // Auto-prefix with +91 if it's 10 digits and lacks a prefix
    if (!phone.startsWith('+')) {
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        _phoneErrorMessage = "Include country code (e.g. +91...)";
        notifyListeners();
        return;
      }
    }

    try {
      await _authProvider.loginWithPhone(
        phone,
        (verificationId, resendToken) {
          _verificationId = verificationId;
          _otpSent = true;
          _isButtonEnabled = false;
          _phoneErrorMessage = null;
          notifyListeners();
          if (context.mounted) {
            AppSnackbar.show(context, message: "OTP Sent to $phone", type: SnackbarType.success);
          }
        },
        onError: (errorMsg) {
          _phoneErrorMessage = errorMsg;
          notifyListeners();
          if (context.mounted) {
            AppSnackbar.show(context, message: errorMsg, type: SnackbarType.error);
          }
        },
        onAutoVerify: () {
          if (context.mounted) {
            AppSnackbar.show(context, message: "Phone verified automatically!", type: SnackbarType.success);
          }
          // AuthWrapper will handle navigation
        },
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, message: "Failed: $e", type: SnackbarType.error);
      }
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (_verificationId == null) {
      if (context.mounted) {
        AppSnackbar.show(context, message: "Invalid session. Please resend OTP.", type: SnackbarType.error);
      }
      return;
    }

    try {
      await _authProvider.verifyOtp(_verificationId!, otpController.text.trim());
      // AuthWrapper handles navigation
    } catch (e) {
      _otpErrorMessage = "Invalid OTP";
      notifyListeners();
      if (context.mounted) {
        AppSnackbar.show(context, message: "Invalid OTP", type: SnackbarType.error);
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
