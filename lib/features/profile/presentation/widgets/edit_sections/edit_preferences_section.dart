import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import 'edit_section_container.dart';
import '../../../../../core/widgets/app_select.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_data_constants.dart';

class EditPreferencesSection extends StatelessWidget {
  final EditProfileController controller;

  const EditPreferencesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.draftProfile!;

    return EditSectionContainer(
      title: "Preferences",
      icon: Icons.tune_rounded,
      children: [
        AppSelect<String>(
          label: "Looking For",
          selectedValue: profile.lookingFor,
          items: AppDataConstants.lookingForOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(lookingFor: val)),
        ),

        _buildAgeRange(context, profile),

        _buildDistance(context, profile),
      ],
    );
  }

  Widget _buildAgeRange(BuildContext context, dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Age Range",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              "${profile.minAge ?? 18} - ${profile.maxAge ?? 50}",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            (profile.minAge ?? 18).toDouble(),
            (profile.maxAge ?? 50).toDouble(),
          ),
          min: 18,
          max: 80,
          divisions: 62,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white10,
          onChanged: (RangeValues values) {
            controller.updateDraft(
              (p) => p.copyWith(
                minAge: values.start.round(),
                maxAge: values.end.round(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDistance(BuildContext context, dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Max Distance",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              "${profile.distance ?? 50} km",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: (profile.distance ?? 50).toDouble(),
          min: 1,
          max: 500,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white10,
          onChanged: (val) {
            controller.updateDraft((p) => p.copyWith(distance: val.round()));
          },
        ),
      ],
    );
  }
}
