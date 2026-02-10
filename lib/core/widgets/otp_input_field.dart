import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../constants/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final int otpLength;
  final Function(String) onOtpComplete;
  final bool showError;

  const OtpInputField({
    super.key,
    this.otpLength = 6,
    required this.onOtpComplete,
    this.showError = false,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> with CodeAutoFill {
  late final TextEditingController _pinController;
  late final FocusNode _focusNode;
  String? _appSignature;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _focusNode = FocusNode();
    _initAutoFill();
  }

  Future<void> _initAutoFill() async {
    try {
      // Get app signature for Android SMS Retriever API
      _appSignature = await SmsAutoFill().getAppSignature;
      debugPrint("App Signature for SMS Retriever: $_appSignature");
      
      // Start listening for SMS
      listenForCode();
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing SMS autofill: $e");
    }
  }

  @override
  void codeUpdated() {
    if (code != null && mounted) {
      _pinController.text = code!;
      widget.onOtpComplete(code!);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pinput(
          length: widget.otpLength,
          controller: _pinController,
          focusNode: _focusNode,
          onCompleted: (pin) {
            debugPrint('OTP Completed: $pin');
            widget.onOtpComplete(pin);
          },
          autofillHints: const [AutofillHints.oneTimeCode],
          defaultPinTheme: widget.showError ? errorPinTheme : defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          errorPinTheme: errorPinTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 22,
                height: 2,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        if (_appSignature != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              "Waiting for SMS...",
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
