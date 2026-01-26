import 'package:flutter/material.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/widgets/app_toggle_switch.dart';

class StepLifestyle extends StatefulWidget {
  @override
  State<StepLifestyle> createState() => _StepLifestyleState();
}

class _StepLifestyleState extends State<StepLifestyle> {
  String drinkingFrequency = 'never';
  String drinkingChoice = 'yes';

  String? exercise;
  String? diet;
  String? pets;
  String? religion;
  String? language;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'Lifestyle Preferences',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lorem ipsum dolor sit amet consectetur proin habitasse lacus senectus bibendum nibh egestas.',
          style: TextStyle(color: Colors.white60),
        ),

        const SizedBox(height: 24),

        /// Drinking Frequency
        AppSelect<String>(
          label: 'Drinking',
          hint: 'Select option',
          selectedValue: drinkingFrequency,
          items: const [
            DropdownMenuItem(value: 'never', child: Text('Never')),
            DropdownMenuItem(
              value: 'occasionally',
              child: Text('Occasionally'),
            ),
            DropdownMenuItem(value: 'often', child: Text('Often')),
          ],
          onChanged: (v) => setState(() => drinkingFrequency = v!),
        ),

        const SizedBox(height: 20),

        /// Drinking Yes / No Toggle
        AppToggleSwitch(
          title: 'Drinking',
          selectedValue: drinkingChoice,
          options: const [
            AppToggleOption(label: 'Yes', value: 'yes'),
            AppToggleOption(label: 'No', value: 'no'),
          ],
          onChanged: (v) => setState(() => drinkingChoice = v),
        ),

        const SizedBox(height: 20),

        /// Exercise
        AppSelect<String>(
          label: 'Exercise',
          hint: 'Select activity level',
          selectedValue: exercise,
          items: const [
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
            DropdownMenuItem(value: 'lazy', child: Text('Lazy')),
          ],
          onChanged: (v) => setState(() => exercise = v),
        ),

        const SizedBox(height: 20),

        /// Diet
        AppSelect<String>(
          label: 'Diet',
          hint: 'Select diet',
          selectedValue: diet,
          items: const [
            DropdownMenuItem(value: 'veg', child: Text('Vegetarian')),
            DropdownMenuItem(value: 'non-veg', child: Text('Non-Vegetarian')),
            DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
          ],
          onChanged: (v) => setState(() => diet = v),
        ),

        const SizedBox(height: 20),

        /// Pets
        AppSelect<String>(
          label: 'Pets',
          hint: 'Select preference',
          selectedValue: pets,
          items: const [
            DropdownMenuItem(value: 'cat', child: Text('Cat lover')),
            DropdownMenuItem(value: 'dog', child: Text('Dog lover')),
            DropdownMenuItem(value: 'none', child: Text('No pets')),
          ],
          onChanged: (v) => setState(() => pets = v),
        ),

        const SizedBox(height: 20),

        /// Religion (Optional)
        AppSelect<String>(
          label: 'Religion (Optional)',
          hint: '-',
          selectedValue: religion,
          items: const [
            DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
            DropdownMenuItem(value: 'christian', child: Text('Christian')),
            DropdownMenuItem(value: 'muslim', child: Text('Muslim')),
          ],
          onChanged: (v) => setState(() => religion = v),
        ),

        const SizedBox(height: 20),

        /// Language
        AppSelect<String>(
          label: 'Language',
          hint: 'Select language',
          selectedValue: language,
          items: const [
            DropdownMenuItem(value: 'english', child: Text('English')),
            DropdownMenuItem(value: 'tamil', child: Text('Tamil')),
            DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
          ],
          onChanged: (v) => setState(() => language = v),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
