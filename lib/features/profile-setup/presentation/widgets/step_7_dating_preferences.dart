import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_select.dart';
import '../../../../core/widgets/app_interest_selector.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepDatingPreferences extends StatelessWidget {
  const StepDatingPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    final profile = profileProvider.draftProfile;

    return ListView(
      children: [
        const Text(
          'Dating Preferences',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AppSelect<String>(
          label: 'Looking For',
          hint: 'Select option',
          selectedValue: profile?.lookingFor,
          items: const [
            DropdownMenuItem(value: 'Relationship', child: Text('Relationship')),
            DropdownMenuItem(value: 'Friendship', child: Text('Friendship')),
            DropdownMenuItem(value: 'Casual', child: Text('Casual')),
          ],
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(lookingFor: v)),
        ),
        const SizedBox(height: 16),
        
        // Simulating Age/Distance range with a select for simplicity in this example
        AppSelect<int>(
          label: 'Preferred Age Range',
          hint: 'Select min age',
          selectedValue: profile?.minAge,
          items: List.generate(50, (index) => index + 18).map((age) {
            return DropdownMenuItem(value: age, child: Text('$age+'));
          }).toList(),
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(minAge: v, maxAge: (v ?? 18) + 10)),
        ),
        const SizedBox(height: 16),

        AppSelect<int>(
          label: 'Distance Range (km)',
          hint: 'Select range',
          selectedValue: profile?.distance,
          items: [10, 20, 50, 100, 500].map((d) {
            return DropdownMenuItem(value: d, child: Text('$d km'));
          }).toList(),
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(distance: v)),
        ),
        const SizedBox(height: 16),

        const Text(
          'Interests',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        AppInterestSelector(
          selectedInterests: profile?.interests ?? [],
          onChanged: (interests) {
            profileProvider.updateProfile((p) => p.copyWith(interests: interests));
          },
        ),
      ],
    );
  }
}
