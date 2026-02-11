import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/providers/profile_setup_provider.dart';
import '../../../../core/constants/app_data_constants.dart';

class StepLifestyle extends StatelessWidget {
  const StepLifestyle({super.key});

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
              'Lifestyle Details',
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
              'Sharing your lifestyle helps in finding someone with similar interests.',
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
              label: 'Smoking',
              hint: 'Select option',
              selectedValue: profile?.smoking,
              showError: profileProvider.errors.containsKey('smoking'),
              errorMessage: profileProvider.errors['smoking'],
              items: AppDataConstants.smokingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(smoking: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: AppSelect<String>(
              label: 'Drinking',
              hint: 'Select option',
              selectedValue: profile?.drinking,
              showError: profileProvider.errors.containsKey('drinking'),
              errorMessage: profileProvider.errors['drinking'],
              items: AppDataConstants.drinkingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(drinking: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: AppSelect<String>(
              label: 'Exercise',
              hint: 'Select option',
              selectedValue: profile?.exercise,
              showError: profileProvider.errors.containsKey('exercise'),
              errorMessage: profileProvider.errors['exercise'],
              items: AppDataConstants.exerciseOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(exercise: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: AppSelect<String>(
              label: 'Diet',
              hint: 'Select option',
              selectedValue: profile?.diet,
              showError: profileProvider.errors.containsKey('diet'),
              errorMessage: profileProvider.errors['diet'],
              items: AppDataConstants.dietOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(diet: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: AppSelect<String>(
              label: 'Pets',
              hint: 'Select option',
              selectedValue: profile?.pets,
              showError: profileProvider.errors.containsKey('pets'),
              errorMessage: profileProvider.errors['pets'],
              items: AppDataConstants.petOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(pets: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: AppSelect<String>(
              label: 'Religion (Optional)',
              hint: 'Select religion',
              selectedValue: profile?.religion,
              items: AppDataConstants.religionOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(religion: v)),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: AppSelect<String>(
              label: 'Language',
              hint: 'Select language',
              selectedValue: profile?.language,
              showError: profileProvider.errors.containsKey('language'),
              errorMessage: profileProvider.errors['language'],
              items: AppDataConstants.languageOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(language: v)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
