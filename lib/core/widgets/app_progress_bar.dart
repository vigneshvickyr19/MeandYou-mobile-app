import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;

  const AppProgressBar({super.key, required this.progress, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          /// Background bar
          Container(height: height, color: AppColors.greyDark.withValues(alpha: 0.3)),

          /// Solid fill
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * progress.clamp(0.0, 1.0);

              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),

                  /// Glow/blur tip at the leading edge
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 20,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary.withValues(alpha: 0.6),
                            AppColors.primary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
