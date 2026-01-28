import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return ListView(
      children: [
        const Text(
          'Basic Identity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        AppInput(
          label: 'Full Name',
          hint: 'Enter your name',
          controller: nameCtrl,
          onChanged: (v) {
            profileProvider.updateProfile((p) => p.copyWith(fullName: v));
          },
        ),
        const SizedBox(height: 20),

        AppDatePicker(
          label: 'Date of Birth',
          selectedDate: profile?.dob,
          onDateSelected: (d) {
            profileProvider.updateProfile((p) => p.copyWith(dob: d));
          },
        ),
        const SizedBox(height: 20),

        AppToggleSwitch(
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
      ],
    );
  }
}
