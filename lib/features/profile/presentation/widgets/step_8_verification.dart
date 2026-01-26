import 'package:flutter/material.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_verified_info_tile.dart';

class StepVerification extends StatelessWidget {
  final instagramCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final facebookCtrl = TextEditingController();
  final xCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        const Text(
          'Verification & Contact Info',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),

        /// ✅ Phone (read-only)
        const VerifiedInfoTile(label: 'Phone number', value: '+91 76870 87698'),

        const SizedBox(height: 20),

        /// ✅ Email (read-only)
        const VerifiedInfoTile(label: 'Email', value: 'guyhawkins@email.com'),

        const SizedBox(height: 28),

        /// 🔗 Social Inputs
        AppInput(
          label: 'Instagram',
          hint: 'www.instagram.com',
          controller: instagramCtrl,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 20),

        AppInput(
          label: 'LinkedIn',
          hint: 'www.linkedin.com',
          controller: linkedinCtrl,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 20),

        AppInput(
          label: 'Facebook',
          hint: 'www.facebook.com',
          controller: facebookCtrl,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 20),

        AppInput(
          label: 'X',
          hint: 'www.x.com',
          controller: xCtrl,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
