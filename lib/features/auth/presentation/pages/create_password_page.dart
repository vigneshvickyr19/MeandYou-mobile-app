import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _showPasswordError = false;
  bool _showConfirmError = false;
  bool _isButtonEnabled = false;

  void _validateInput() {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    bool isValid = password.length >= 6 && password == confirm;

    setState(() {
      _isButtonEnabled = isValid;
      _showPasswordError = password.isNotEmpty && password.length < 6;
      _showConfirmError = confirm.isNotEmpty && password != confirm;
    });
  }

  void _onSubmit() {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (!_isButtonEnabled) {
      _validateInput();
      AppSnackbar.show(
        context,
        message: "Please fix the errors before proceeding",
        type: SnackbarType.error,
      );
      return;
    }

    AppSnackbar.show(
      context,
      message: "Password created successfully",
      type: SnackbarType.success,
    );

    Navigator.pushReplacementNamed(context, AppRoutes.profileSetupPage);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
              "Create Password",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enter a strong password and confirm it.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            AppInput(
              label: "Password",
              hint: "Enter password",
              controller: _passwordController,
              showError: _showPasswordError,
              errorMessage: "Password must be at least 6 characters",
              onChanged: (_) => _validateInput(),
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "Confirm Password",
              hint: "Confirm password",
              controller: _confirmController,
              showError: _showConfirmError,
              errorMessage: "Passwords do not match",
              onChanged: (_) => _validateInput(),
            ),
            const Spacer(),
            AppButton(
              text: "Create Password",
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
