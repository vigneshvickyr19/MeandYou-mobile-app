import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/widgets/app_interest_selector.dart';

class StepDatingPreferences extends StatefulWidget {
  const StepDatingPreferences({super.key});

  @override
  State<StepDatingPreferences> createState() => _StepDatingPreferencesState();
}

class _StepDatingPreferencesState extends State<StepDatingPreferences> {
  String? lookingFor;
  String? ageRange;
  String? distanceRange;

  List<String> selectedInterests = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Title
        const Text(
          'Dating Preferences',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          'Lorem ipsum dolor sit amet consectetur proin habitasse lacus senectus bibendum nibh egestas.',
          style: TextStyle(color: AppColors.greyDark, fontSize: 13),
        ),

        const SizedBox(height: 28),

        /// Looking For
        AppSelect<String>(
          label: 'Looking for',
          hint: 'Select',
          selectedValue: lookingFor,
          items: const [
            DropdownMenuItem(value: 'Casual', child: Text('Casual')),
            DropdownMenuItem(value: 'Serious', child: Text('Serious')),
            DropdownMenuItem(value: 'Friendship', child: Text('Friendship')),
          ],
          onChanged: (v) {
            setState(() => lookingFor = v);
          },
        ),

        const SizedBox(height: 20),

        /// Preferred Age Range
        AppSelect<String>(
          label: 'Preferred age range',
          hint: 'Select',
          selectedValue: ageRange,
          items: const [
            DropdownMenuItem(value: '18 - 25', child: Text('18 - 25')),
            DropdownMenuItem(value: '20 - 25', child: Text('20 - 25')),
            DropdownMenuItem(value: '25 - 30', child: Text('25 - 30')),
            DropdownMenuItem(value: '30 - 40', child: Text('30 - 40')),
          ],
          onChanged: (v) {
            setState(() => ageRange = v);
          },
        ),

        const SizedBox(height: 20),

        /// Distance Range
        AppSelect<String>(
          label: 'Distance range',
          hint: 'Select',
          selectedValue: distanceRange,
          items: const [
            DropdownMenuItem(value: '1 km', child: Text('1 km')),
            DropdownMenuItem(value: '5 km', child: Text('5 km')),
            DropdownMenuItem(value: '10 km', child: Text('10 km')),
            DropdownMenuItem(value: '25 km', child: Text('25 km')),
          ],
          onChanged: (v) {
            setState(() => distanceRange = v);
          },
        ),

        const SizedBox(height: 28),

        /// Interests
        const Text(
          'Interests selection',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        InterestChipSelector(
          onSelectionChanged: (values) {
            selectedInterests = values;
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
