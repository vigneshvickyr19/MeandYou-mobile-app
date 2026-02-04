import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // Background Radial Glow
                Positioned(
                  top: -50,
                  left: -50,
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
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: const Text(
                                  "Welcome Back",
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
                                  "Login to continue your journey and find meaningful connections.",
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
                                  label: "Email",
                                  hint: "your@email.com",
                                  controller: controller.emailController,
                                  showError: controller.showEmailError,
                                  errorMessage: "Invalid email address",
                                  onChanged: (_) => controller.validateInputs(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 600),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppInput(
                                      label: "Password",
                                      hint: "••••••••",
                                      controller: controller.passwordController,
                                      showError: controller.showPasswordError,
                                      errorMessage: "Password must be at least 6 characters",
                                      onChanged: (_) => controller.validateInputs(),
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                        },
                                        child: Text(
                                          "Forgot password?",
                                          style: TextStyle(
                                            color: AppColors.primary.withValues(alpha: 0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom Actions
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 400),
                                child: AppButton(
                                  text: "Login",
                                  onPressed: () => controller.login(context),
                                  isEnabled: controller.isButtonEnabled,
                                  isLoading: controller.isLoading,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeInUp(
                                delay: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.signUp);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 15),
                                      children: [
                                        TextSpan(
                                          text: "New here? ",
                                          style: TextStyle(color: AppColors.white.withValues(alpha: 0.6)),
                                        ),
                                        const TextSpan(
                                          text: "Create an account",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
