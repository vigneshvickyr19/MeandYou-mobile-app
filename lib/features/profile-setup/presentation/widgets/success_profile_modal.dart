import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/app_custom_modal.dart';

class SuccessProfileModal {
  static Future<void> show(BuildContext context) {
    return AppCustomModal.show(
      context,
      AppCustomModal(
        title: 'Profile Setup Complete',
        description:
            'Your profile has been successfully created. You can now start exploring the app.',
        buttonText: 'Continue',
        topIcon: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.15),
          ),
          child: Center(
            child: SvgPicture.asset(AppImages.tickIcon, height: 36, width: 36),
          ),
        ),
        onButtonPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
      ),
    );
  }
}
