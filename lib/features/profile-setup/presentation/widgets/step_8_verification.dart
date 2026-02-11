import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/widgets/app_verified_info_tile.dart';

class StepVerification extends StatefulWidget {
  const StepVerification({super.key});

  @override
  State<StepVerification> createState() => _StepVerificationState();
}

class _StepVerificationState extends State<StepVerification> {
  late TextEditingController instaCtrl;
  late TextEditingController lnCtrl;
  late TextEditingController fbCtrl;
  late TextEditingController xCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileSetupProvider>(context, listen: false).draftProfile;
    instaCtrl = TextEditingController(text: p?.instagram ?? '');
    lnCtrl = TextEditingController(text: p?.linkedin ?? '');
    fbCtrl = TextEditingController(text: p?.facebook ?? '');
    xCtrl = TextEditingController(text: p?.x ?? '');
  }

  @override
  void dispose() {
    instaCtrl.dispose();
    lnCtrl.dispose();
    fbCtrl.dispose();
    xCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Final Steps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Verify your identity and link your social profiles to build trust.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty
              ? AppVerifiedInfoTile(
                  label: "Phone Number",
                  value: user.phoneNumber!,
                  isVerified: user.isVerified,
                )
              : AppVerifiedInfoTile(
                  label: "Email Address",
                  value: user?.email ?? "Not setup",
                  isVerified: user?.isVerified ?? false,
                ),
          ),

          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: const Text(
              'Social Links',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: AppInput(
              label: 'Instagram',
              hintText: '@username',
              controller: instaCtrl,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(instagram: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: AppInput(
              label: 'LinkedIn',
              hintText: 'linkedin.com/in/username',
              controller: lnCtrl,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(linkedin: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: AppInput(
              label: 'Facebook',
              hintText: 'facebook.com/username',
              controller: fbCtrl,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(facebook: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: AppInput(
              label: 'X (Twitter)',
              hintText: '@username',
              controller: xCtrl,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(x: v)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
