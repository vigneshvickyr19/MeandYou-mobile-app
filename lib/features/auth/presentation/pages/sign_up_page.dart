import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<SignUpController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(
              children: [
                // Background Radial Glow
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                
                SafeArea(
                  child: Column(
                    children: [
                      // Header with Back Button
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
                                  "Create Account",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeInDown(
                                delay: const Duration(milliseconds: 100),
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  "Start your journey with us. Fill in the details below to get started.",
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.5),
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 600),
                                child: AppInput(
                                  label: "Email Address",
                                  hint: "your@email.com",
                                  controller: controller.emailController,
                                  showError: controller.showError,
                                  errorMessage: "Please enter a valid email address",
                                  onChanged: controller.validateEmail,
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  "By continuing, you agree to our Terms of Service and Privacy Policy.",
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom Button
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 400),
                                child: AppButton(
                                  text: "Continue",
                                  onPressed: () => controller.submit(context),
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
