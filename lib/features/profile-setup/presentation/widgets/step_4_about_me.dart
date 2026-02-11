import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_text_area.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepAboutMe extends StatefulWidget {
  const StepAboutMe({super.key});

  @override
  State<StepAboutMe> createState() => _StepAboutMeState();
}

class _StepAboutMeState extends State<StepAboutMe> {
  late TextEditingController bioCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileSetupProvider>(context, listen: false).draftProfile;
    bioCtrl = TextEditingController(text: p?.bio ?? '');
  }

  @override
  void dispose() {
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'About You',
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
              'Showcase your personality! A good bio can make a huge difference.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: AppTextArea(
              label: 'Your Bio',
              hint: 'I love traveling, coffee, and meaningful conversations...',
              controller: bioCtrl,
              showError: profileProvider.errors.containsKey('bio'),
              errorMessage: profileProvider.errors['bio'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(bio: v)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
