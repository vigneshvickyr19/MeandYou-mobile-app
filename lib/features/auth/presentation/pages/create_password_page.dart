import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/auth_provider.dart';

import '../controllers/create_password_controller.dart';

class CreatePasswordPage extends StatelessWidget {
  const CreatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? '';

    return ChangeNotifierProvider(
      create: (_) => CreatePasswordController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<CreatePasswordController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
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
                    "Create password",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Set a secure password for your account.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: "Password",
                    hint: "Enter password",
                    controller: controller.passwordController,
                    onChanged: (_) => controller.validatePasswords(),
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: "Confirm Password",
                    hint: "Confirm your password",
                    controller: controller.confirmPasswordController,
                    showError: controller.showError,
                    errorMessage: "Passwords do not match",
                    onChanged: (_) => controller.validatePasswords(),
                    isPassword: true,
                  ),
                  const Spacer(),
                  AppButton(
                    text: "Create Account",
                    onPressed: () => controller.submit(context, email),
                    isEnabled: controller.isButtonEnabled,
                    isLoading: controller.isLoading,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
