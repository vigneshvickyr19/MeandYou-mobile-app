import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/constants/app_routes.dart';

class VerifyCodeController extends ChangeNotifier {
  final AuthProvider _authProvider;

  final TextEditingController codeController = TextEditingController();
  bool _showError = false;
  bool _isButtonEnabled = false;
  int _resendTimer = 60;
  bool _canResend = false;
  String _otp = '';
  Timer? _timer;
  bool _isDisposed = false;

  VerifyCodeController(this._authProvider) {
    _authProvider.addListener(notifyListeners);
    _startResendTimer();
  }

  bool get showError => _showError;
  bool get isButtonEnabled => _isButtonEnabled;
  bool get isLoading => _authProvider.isLoading;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  int get resendTimer => _resendTimer;
  bool get canResend => _canResend;
  String get otp => _otp;

  void _startResendTimer() {
    _timer?.cancel();
    _resendTimer = 60;
    _canResend = false;
    _safeNotifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        _safeNotifyListeners();
      } else {
        _canResend = true;
        _timer?.cancel();
        _safeNotifyListeners();
      }
    });
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void validateCode(String value) {
    _otp = value;
    // Supporting 4 or 6 digits as per requirement
    _isButtonEnabled = value.trim().length >= 4 && value.trim().length <= 6;
    _showError = value.isNotEmpty && !_isButtonEnabled;
    _safeNotifyListeners();
  }

  Future<void> resendOtp(BuildContext context, String phoneNumber) async {
    if (!_canResend || isLoading) return;

    try {
      await _authProvider.sendOtp(phoneNumber);
      _startResendTimer();
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Code resent successfully!",
          type: SnackbarType.success,
        );
      }
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

  Future<void> verify(
    BuildContext context,
    String phoneNumber,
    String verificationId,
  ) async {
    if (isLoading) return;

    final code = _otp.isEmpty ? codeController.text.trim() : _otp;

    if (verificationId.isEmpty) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: "Empty verification ID. Please go back and try again.",
          type: SnackbarType.error,
        );
      }
      return;
    }

    if (!_isButtonEnabled) {
      _showError = true;
      _safeNotifyListeners();
      return;
    }

    try {
      debugPrint("Verifying OTP: $code for ID: $verificationId");
      await _authProvider.verifyOtp(verificationId, code);

      if (context.mounted) {
        debugPrint("OTP Verified Successfully. Navigating to AuthWrapper...");
        // Reset stack and let AuthWrapper decide (Home vs Profile Setup)
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.authWrapper,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("OTP Verification Error: $e");
      if (context.mounted) {
        String msg = "Incorrect code. Please check and try again.";
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-verification-code') {
            msg = "The code you entered is invalid.";
          } else if (e.code == 'session-expired') {
            msg =
                "The verification code has expired. Please request a new one.";
          } else if (e.code == 'network-request-failed') {
            msg = "Network error. Please check your connection.";
          } else {
            msg = e.message ?? msg;
          }
        } else {
          // Strip 'Exception: ' prefix for cleaner UI messages if it exists
          msg = e.toString().replaceFirst('Exception: ', '');
        }

        AppSnackbar.show(context, message: msg, type: SnackbarType.error);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _authProvider.removeListener(notifyListeners);
    codeController.dispose();
    super.dispose();
  }
}
