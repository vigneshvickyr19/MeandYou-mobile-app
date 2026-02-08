import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
    final phoneNumber = args?['phoneNumber'] ?? '';
    final verificationId = args?['verificationId'] ?? '';

    return ChangeNotifierProvider(
      create: (_) => VerifyCodeController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<VerifyCodeController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(
              children: [
                // Background Glow
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const AppBackButton(),
                            const Spacer(),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: const Text(
                                  "Verify Identity",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FadeInDown(
                                delay: const Duration(milliseconds: 100),
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  "We've sent a 6-digit verification code to $phoneNumber. Please enter it below.",
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.6),
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 600),
                                child: AppInput(
                                  label: "Verification Code",
                                  hint: "4 or 6 digit code",
                                  controller: controller.codeController,
                                  keyboardType: TextInputType.number,
                                  showError: controller.showError,
                                  errorMessage: "Please enter a valid code",
                                  onChanged: controller.validateCode,
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 600),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      // Resend logic could be added here
                                    },
                                    child: const Text(
                                      "Didn't receive code? Resend",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 400),
                                child: AppButton(
                                  text: "Verify OTP",
                                  onPressed: () => controller.verify(context, phoneNumber, verificationId),
                                  isEnabled: controller.isButtonEnabled,
                                  isLoading: controller.isLoading,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
