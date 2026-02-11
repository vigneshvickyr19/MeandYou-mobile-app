import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepBasicIdentity extends StatefulWidget {
  const StepBasicIdentity({super.key});

  @override
  State<StepBasicIdentity> createState() => _StepBasicIdentityState();
}

class _StepBasicIdentityState extends State<StepBasicIdentity> {
  late TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    nameCtrl = TextEditingController(text: profileProvider.draftProfile?.fullName ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final profile = profileProvider.draftProfile;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Essential Identity',
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
              'Let us start with the basics to help people know who you are.',
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
              label: 'Display Name',
              hintText: 'What should we call you?',
              controller: nameCtrl,
              showError: profileProvider.errors.containsKey('fullName'),
              errorMessage: profileProvider.errors['fullName'],
              onChanged: (v) {
                profileProvider.updateProfile((p) => p.copyWith(fullName: v));
              },
            ),
          ),
          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: AppDatePicker(
              label: 'Birth Date${profileProvider.age != null ? ' (Age: ${profileProvider.age})' : ''}',
              selectedDate: profile?.dob,
              showError: profileProvider.errors.containsKey('dob'),
              errorMessage: profileProvider.errors['dob'],
              onDateSelected: (d) {
                profileProvider.updateProfile((p) => p.copyWith(dob: d));
              },
            ),
          ),
          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: AppToggleSwitch(
              title: 'Gender',
              selectedValue: profile?.gender ?? 'male',
              onChanged: (v) {
                profileProvider.updateProfile((p) => p.copyWith(gender: v));
              },
              options: [
                AppToggleOption(
                  label: 'Male',
                  value: 'male',
                  svgPath: AppImages.faceMaleIcon,
                ),
                AppToggleOption(
                  label: 'Female',
                  value: 'female',
                  svgPath: AppImages.faceFemaleIcon,
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
