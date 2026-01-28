import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  Text(
                    controller.otpSent ? "Verify Phone" : "Login with Phone",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (!controller.otpSent)
                    AppInput(
                      label: "Phone Number",
                      hint: "+91 234 567 890",
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: controller.validatePhone,
                      showError: controller.phoneErrorMessage != null,
                      errorMessage: controller.phoneErrorMessage,
                    )
                  else
                    AppInput(
                      label: "Enter 6-digit OTP",
                      hint: "123456",
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      onChanged: controller.validateOtp,
                      showError: controller.otpErrorMessage != null,
                      errorMessage: controller.otpErrorMessage,
                    ),

                  const Spacer(),
                  AppButton(
                    text: controller.otpSent ? "Verify & Login" : "Send OTP",
                    onPressed: () => controller.otpSent 
                        ? controller.verifyOtp(context) 
                        : controller.sendOtp(context),
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
