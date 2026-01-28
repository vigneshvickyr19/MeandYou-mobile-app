import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/auth_provider.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 Top Image
            Expanded(
              flex: 4,
              child: Image.asset(
                AppImages.getStarted,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            // 🔽 Content
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get started',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with people and start meaningful conversations.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Sign Up Buttons
                    AppButton(
                      text: 'Sign up with Google',
                      iconPath: AppImages.google,
                      type: AppButtonType.transparent,
                      onPressed: () async {
                        try {
                          await Provider.of<AuthProvider>(context, listen: false).loginWithGoogle();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google Sign-In failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    AppButton(
                      text: 'Sign up with Apple',
                      iconPath: AppImages.apple,
                      type: AppButtonType.transparent,
                      onPressed: () {
                        // Add Apple auth flow here
                      },
                    ),
                    const SizedBox(height: 12),

                    AppButton(
                      text: 'Sign up with Email',
                      iconPath: AppImages.sms,
                      type: AppButtonType.transparent,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                    ),
                    const SizedBox(height: 12),

                    AppButton(
                      text: 'Sign up with Phone number',
                      iconPath: AppImages.phone,
                      type: AppButtonType.transparent,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.phoneLogin);
                      },
                    ),

                    const Spacer(),

                    // 🔹 Already have account? Log in
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log in',
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
