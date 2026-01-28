import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepQuickStats extends StatefulWidget {
  const StepQuickStats({super.key});

  @override
  State<StepQuickStats> createState() => _StepQuickStatsState();
}

class _StepQuickStatsState extends State<StepQuickStats> {
  late TextEditingController heightCtrl;
  late TextEditingController jobCtrl;
  late TextEditingController eduCtrl;
  late TextEditingController homeCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileSetupProvider>(context, listen: false).draftProfile;
    heightCtrl = TextEditingController(text: p?.height?.toString() ?? '');
    jobCtrl = TextEditingController(text: p?.jobTitle ?? '');
    eduCtrl = TextEditingController(text: p?.education ?? '');
    homeCtrl = TextEditingController(text: p?.hometown ?? '');
  }

  @override
  void dispose() {
    heightCtrl.dispose();
    jobCtrl.dispose();
    eduCtrl.dispose();
    homeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);

    return ListView(
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AppInput(
          label: 'Height (cm)',
          hint: '175',
          controller: heightCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(height: int.tryParse(v))),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Job Title',
          hint: 'e.g. Software Engineer',
          controller: jobCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(jobTitle: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Education',
          hint: 'e.g. Bachelors in Arts',
          controller: eduCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(education: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Hometown',
          hint: 'e.g. New York',
          controller: homeCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(hometown: v)),
        ),
      ],
    );
  }
}
