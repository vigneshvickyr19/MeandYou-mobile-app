import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/auth_provider.dart';

import '../controllers/verify_code_controller.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? '';

    return ChangeNotifierProvider(
      create: (_) => VerifyCodeController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<VerifyCodeController>(
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
                    "Verify Code",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Enter the 6-digit code sent to your email.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: "Verification Code",
                    hint: "Enter code",
                    controller: controller.codeController,
                    showError: controller.showError,
                    errorMessage: "Invalid code",
                    onChanged: controller.validateCode,
                  ),
                  const Spacer(),
                  AppButton(
                    text: "Verify",
                    onPressed: () => controller.verify(context, email),
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
