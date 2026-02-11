import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Quick Stats',
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
              'Add some key details to help people understand your lifestyle.',
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
              label: 'Height (cm)',
              hint: '175',
              controller: heightCtrl,
              showError: profileProvider.errors.containsKey('height'),
              errorMessage: profileProvider.errors['height'],
              keyboardType: TextInputType.number,
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(height: int.tryParse(v))),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: AppInput(
              label: 'Job Title',
              hint: 'e.g. Software Engineer',
              controller: jobCtrl,
              showError: profileProvider.errors.containsKey('jobTitle'),
              errorMessage: profileProvider.errors['jobTitle'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(jobTitle: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: AppInput(
              label: 'Education',
              hint: 'e.g. Bachelors in Science',
              controller: eduCtrl,
              showError: profileProvider.errors.containsKey('education'),
              errorMessage: profileProvider.errors['education'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(education: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: AppInput(
              label: 'Hometown',
              hint: 'e.g. New York',
              controller: homeCtrl,
              showError: profileProvider.errors.containsKey('hometown'),
              errorMessage: profileProvider.errors['hometown'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(hometown: v)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
