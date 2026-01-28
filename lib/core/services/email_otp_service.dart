import 'dart:math';
import 'package:flutter/foundation.dart';

class EmailOtpService {
  // Simple in-memory storage for codes
  static final Map<String, String> _otpStorage = {};

  static Future<void> sendOtp(String email) async {
    // In a real app, this would call a Cloud Function or an API
    // to send an email via SendGrid, Mailgun, etc.
    String code = (100000 + Random().nextInt(900000)).toString();
    _otpStorage[email] = code;
    
    debugPrint('--- MOCK EMAIL OTP ---');
    debugPrint('To: $email');
    debugPrint('Code: $code');
    debugPrint('----------------------');
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
  }

  static bool verifyOtp(String email, String code) {
    if (_otpStorage.containsKey(email) && _otpStorage[email] == code) {
      _otpStorage.remove(email);
      return true;
    }
    return false;
  }
}
