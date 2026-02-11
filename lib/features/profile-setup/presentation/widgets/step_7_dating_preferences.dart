import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/widgets/app_interest_selector.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/constants/app_data_constants.dart';

class StepDatingPreferences extends StatelessWidget {
  const StepDatingPreferences({super.key});

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
              'Preferences',
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
              'What kind of connections are you looking for? Let others know!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: AppSelect<String>(
              label: 'Looking For',
              hint: 'Select option',
              selectedValue: profile?.lookingFor,
              showError: profileProvider.errors.containsKey('lookingFor'),
              errorMessage: profileProvider.errors['lookingFor'],
              items: AppDataConstants.lookingForOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(lookingFor: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: AppSelect<int>(
              label: 'Min Preferred Age',
              hint: 'Select age',
              selectedValue: profile?.minAge,
              items: List.generate(50, (index) => index + 18).map((age) {
                return DropdownMenuItem(value: age, child: Text('$age+'));
              }).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(minAge: v, maxAge: (v ?? 18) + 15)),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: AppSelect<int>(
              label: 'Distance Preference (km)',
              hint: 'Select range',
              selectedValue: profile?.distance,
              items: AppDataConstants.distanceOptions.map((d) {
                return DropdownMenuItem(value: d, child: Text('$d km'));
              }).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(distance: v)),
            ),
          ),
          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: const Text(
              'Your Interests',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: AppInterestSelector(
              selectedInterests: profile?.interests ?? [],
              onChanged: (interests) {
                profileProvider.updateProfile((p) => p.copyWith(interests: interests));
              },
            ),
          ),
          const SizedBox(height: 12),
          if (profileProvider.errors.containsKey('interests'))
            Text(
              profileProvider.errors['interests']!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
