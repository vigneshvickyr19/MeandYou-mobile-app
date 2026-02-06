import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/phone_login_controller.dart';

class PhoneLoginPage extends StatelessWidget {
  const PhoneLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhoneLoginController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<PhoneLoginController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(
              children: [
                // Background Radial Glow
                Positioned(
                  top: -60,
                  left: -60,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  controller.otpSent ? "Verification" : "Phone Login",
                                  style: const TextStyle(
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
                                  controller.otpSent 
                                      ? "We've sent a 6-digit code to your phone number for verification."
                                      : "Enter your phone number to receive a secure login code via SMS.",
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.5),
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              
                              if (!controller.otpSent)
                                FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  child: AppInput(
                                    label: "Phone Number",
                                    hint: "+91 234 567 890",
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    onChanged: controller.validatePhone,
                                    showError: controller.phoneErrorMessage != null,
                                    errorMessage: controller.phoneErrorMessage,
                                  ),
                                )
                              else
                                FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppInput(
                                        label: "Enter 6-digit OTP",
                                        hint: "123456",
                                        controller: controller.otpController,
                                        keyboardType: TextInputType.number,
                                        onChanged: controller.validateOtp,
                                        showError: controller.otpErrorMessage != null,
                                        errorMessage: controller.otpErrorMessage,
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: controller.isLoading ? null : () => controller.sendOtp(context),
                                          child: Text(
                                            "Resend Code",
                                            style: TextStyle(
                                              color: AppColors.primary.withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                                  text: controller.otpSent ? "Verify & Continue" : "Send Verification Code",
                                  onPressed: () => controller.otpSent 
                                      ? controller.verifyOtp(context) 
                                      : controller.sendOtp(context),
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
