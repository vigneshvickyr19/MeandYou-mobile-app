import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepLifestyle extends StatelessWidget {
  const StepLifestyle({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final profile = profileProvider.draftProfile;

    return ListView(
      children: [
        const Text(
          'Lifestyle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AppSelect<String>(
          label: 'Smoking',
          hint: 'Select option',
          selectedValue: profile?.smoking,
          items: const [
            DropdownMenuItem(value: 'Non-smoker', child: Text('Non-smoker')),
            DropdownMenuItem(value: 'Smoker', child: Text('Smoker')),
            DropdownMenuItem(value: 'Social smoker', child: Text('Social smoker')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(smoking: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Drinking',
          hint: 'Select option',
          selectedValue: profile?.drinking,
          items: const [
            DropdownMenuItem(value: 'Non-drinker', child: Text('Non-drinker')),
            DropdownMenuItem(value: 'Social drinker', child: Text('Social drinker')),
            DropdownMenuItem(value: 'Frequent drinker', child: Text('Frequent drinker')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(drinking: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Exercise',
          hint: 'Select option',
          selectedValue: profile?.exercise,
          items: const [
            DropdownMenuItem(value: 'Active', child: Text('Active')),
            DropdownMenuItem(value: 'Sometimes', child: Text('Sometimes')),
            DropdownMenuItem(value: 'Never', child: Text('Never')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(exercise: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Diet',
          hint: 'Select option',
          selectedValue: profile?.diet,
          items: const [
            DropdownMenuItem(value: 'Vegetarian', child: Text('Vegetarian')),
            DropdownMenuItem(value: 'Non-Vegetarian', child: Text('Non-Vegetarian')),
            DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(diet: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Pets',
          hint: 'Select option',
          selectedValue: profile?.pets,
          items: const [
            DropdownMenuItem(value: 'Dog lover', child: Text('Dog lover')),
            DropdownMenuItem(value: 'Cat lover', child: Text('Cat lover')),
            DropdownMenuItem(value: 'No pets', child: Text('No pets')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(pets: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Religion (Optional)',
          hint: 'Select religion',
          selectedValue: profile?.religion,
          items: const [
            DropdownMenuItem(value: 'Christian', child: Text('Christian')),
            DropdownMenuItem(value: 'Muslim', child: Text('Muslim')),
            DropdownMenuItem(value: 'Hindu', child: Text('Hindu')),
            DropdownMenuItem(value: 'None', child: Text('None')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(religion: v)),
        ),
        const SizedBox(height: 16),
        AppSelect<String>(
          label: 'Language',
          hint: 'Select language',
          selectedValue: profile?.language,
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
            DropdownMenuItem(value: 'French', child: Text('French')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(language: v)),
        ),
      ],
    );
  }
}
