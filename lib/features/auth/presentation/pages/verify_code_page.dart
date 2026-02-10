import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_routes.dart';
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
          // Auto-navigation if verified (e.g., via SMS auto-retrieval)
          if (controller.isAuthenticated && !controller.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRoutes.authWrapper, 
                  (route) => false
                );
              }
            });
          }

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
                                  "Enter code",
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
                                  "We sent a verification code to your phone\n$phoneNumber",
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
                                child: OtpInputField(
                                  otpLength: args?['otpLength'] ?? 6,
                                  showError: controller.showError,
                                  onOtpComplete: (otp) {
                                    controller.validateCode(otp);
                                    if (otp.length == (args?['otpLength'] ?? 6)) {
                                      controller.verify(context, phoneNumber, verificationId);
                                    }
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 600),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 4,
                                    runSpacing: 8,
                                    children: [
                                      Text(
                                        "You didn’t receive any code? ",
                                        style: TextStyle(
                                          color: AppColors.white.withValues(alpha: 0.7),
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: controller.canResend 
                                          ? () => controller.resendOtp(context, phoneNumber)
                                          : null,
                                        child: Text(
                                          controller.canResend 
                                            ? "Resend Code" 
                                            : "Resend Code in ${controller.resendTimer}s",
                                          style: TextStyle(
                                            color: controller.canResend 
                                              ? AppColors.secondary 
                                              : AppColors.secondary.withValues(alpha: 0.5),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
