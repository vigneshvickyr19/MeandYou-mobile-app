import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Short Bio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Write a short description about yourself.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        AppTextArea(
          label: 'About Me',
          hint: 'Write something interesting...',
          controller: bioCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(bio: v)),
        ),
      ],
    );
  }
}
