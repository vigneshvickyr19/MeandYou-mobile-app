import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _showError = false;
  bool _isButtonEnabled = false;

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isButtonEnabled = emailRegex.hasMatch(value);
      _showError = value.isNotEmpty && !_isButtonEnabled;
    });
  }

  void _onSubmit() {
    final email = _emailController.text.trim();
    if (!_isButtonEnabled) {
      setState(() => _showError = true);
      AppSnackbar.show(
        context,
        message: "Please enter a valid email",
        type: SnackbarType.error,
      );
      return;
    }

    AppSnackbar.show(
      context,
      message: "Password reset link sent to $email",
      type: SnackbarType.success,
    );

    // Navigate back or to login after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppBackButton(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Forgot Password",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your email to reset your password. We’ll send a link to your email.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),

            AppInput(
              label: "Email",
              hint: "Enter your email",
              controller: _emailController,
              showError: _showError,
              errorMessage: "Invalid email address",
              onChanged: _validateEmail,
            ),

            const Spacer(),

            AppButton(
              text: "Send Reset Link",
              onPressed: _onSubmit,
              isEnabled: _isButtonEnabled,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
