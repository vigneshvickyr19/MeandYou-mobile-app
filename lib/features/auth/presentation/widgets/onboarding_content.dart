import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingModel data;
  final int index;

  const OnboardingContent({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Center image card stack
          Expanded(
            child: Center(
              child: FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background card 2
                    Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: 200,
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Background card 1
                    Transform.rotate(
                      angle: 0.1,
                      child: Container(
                        width: 210,
                        height: 290,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Main Card
                    Container(
                      width: 240,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          data.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Hearts Decoration
                    Positioned(
                      top: 20,
                      right: 20,
                      child: FadeIn(
                        delay: const Duration(milliseconds: 500),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: -10,
                      child: FadeIn(
                        delay: const Duration(milliseconds: 700),
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Primary heading text with highlighted word
          FadeInLeft(
            duration: const Duration(milliseconds: 800),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -1,
                ),
                children: [
                  TextSpan(text: data.title),
                  TextSpan(
                    text: data.highlightedText,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(text: data.suffixText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Short description text
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.6),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
