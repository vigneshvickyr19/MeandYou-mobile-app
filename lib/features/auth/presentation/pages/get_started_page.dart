import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
      body: Stack(
        children: [
          // Background Gradient/Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
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
                // 🔝 Top Image
                Expanded(
                  flex: 4,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            AppImages.getStarted,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
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
                        FadeInLeft(
                          duration: const Duration(milliseconds: 800),
                          child: const Text(
                            'Discover Your\nPerfect Match',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInLeft(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Join the community where meaningful connections are made every day.',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 🔹 Sign Up Buttons
                        _buildAuthButtons(context),

                        const Spacer(),

                        // 🔹 Already have account? Log in
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.login);
                              },
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 15,
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
                        ),
                        const SizedBox(height: 24),
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
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: AppButton(
            text: 'Sign up with Google',
            iconPath: AppImages.google,
            type: AppButtonType.transparent,
            onPressed: () async {
              try {
                await Provider.of<AuthProvider>(context, listen: false).loginWithGoogle();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                      content: Text('Google Sign-In failed: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: AppButton(
            text: 'Sign up with Email',
            iconPath: AppImages.sms,
            type: AppButtonType.transparent,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signUp);
            },
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: AppButton(
            text: 'Sign up with Phone',
            iconPath: AppImages.phone,
            type: AppButtonType.transparent,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.phoneLogin);
            },
          ),
        ),
      ],
    );
  }
}
