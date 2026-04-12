import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_text_area.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/constants/app_colors.dart';
import 'ai_bio_bottom_sheet.dart';

class StepAboutMe extends StatefulWidget {
  const StepAboutMe({super.key});

  @override
  State<StepAboutMe> createState() => _StepAboutMeState();
}

class _StepAboutMeState extends State<StepAboutMe> {
  late TextEditingController bioCtrl;
  late TextEditingController personalityCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileSetupProvider>(context, listen: false).draftProfile;
    bioCtrl = TextEditingController(text: p?.bio ?? '');
    personalityCtrl = TextEditingController(text: p?.personality ?? '');
  }

  @override
  void dispose() {
    bioCtrl.dispose();
    personalityCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAiSuggestions(ProfileSetupProvider provider) async {
    final p = provider.draftProfile;
    if (p == null) return;

    final interests = p.interests?.join(', ') ?? '';
    final personality = personalityCtrl.text.isEmpty 
        ? 'Energetic and friendly' 
        : personalityCtrl.text;

    final selectedBio = await AiBioBottomSheet.show(
      context,
      interests: interests,
      personality: personality,
    );

    if (selectedBio != null && mounted) {
      setState(() {
        bioCtrl.text = selectedBio;
      });
      provider.updateProfile((p) => p.copyWith(bio: selectedBio));
    }
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
            child: AppInput(
              label: 'Describe your vibe (Personality)',
              hintText: 'e.g. Sarcastic, movie buff, adventurous',
              controller: personalityCtrl,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(personality: v)),
            ),
          ),
          const SizedBox(height: 24),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Bio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _handleAiSuggestions(profileProvider),
                      icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                      label: const Text(
                        'AI Suggestion',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppTextArea(
                  label: '', // Hidden as we use the Row above
                  hintText: 'I love traveling, coffee, and meaningful conversations...',
                  controller: bioCtrl,
                  showError: profileProvider.errors.containsKey('bio'),
                  errorMessage: profileProvider.errors['bio'],
                  onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(bio: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
