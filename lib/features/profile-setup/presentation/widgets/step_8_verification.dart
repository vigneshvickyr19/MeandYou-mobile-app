import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return ListView(
      children: [
        const Text(
          'Verification & Socials',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Display Auth Verification Status
        if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
          AppVerifiedInfoTile(
            label: "Phone Number",
            value: user.phoneNumber!,
            isVerified: user.isVerified,
          )
        else
          AppVerifiedInfoTile(
            label: "Email Address",
            value: user?.email ?? "Not setup",
            isVerified: user?.isVerified ?? false,
          ),

        const SizedBox(height: 32),
        const Text(
          'Social Link Connections',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Instagram',
          hint: 'Link to profile',
          controller: instaCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(instagram: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'LinkedIn',
          hint: 'Link to profile',
          controller: lnCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(linkedin: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Facebook',
          hint: 'Link to profile',
          controller: fbCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(facebook: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'X (Twitter)',
          hint: 'Link to profile',
          controller: xCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(x: v)),
        ),
      ],
    );
  }
}
