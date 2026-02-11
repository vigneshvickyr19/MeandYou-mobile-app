import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import 'edit_section_container.dart';
import '../../../../../core/widgets/app_select.dart';
import '../../../../../core/constants/app_data_constants.dart';

class EditLifestyleSection extends StatelessWidget {
  final EditProfileController controller;

  const EditLifestyleSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.draftProfile!;

    return EditSectionContainer(
      title: "Lifestyle",
      icon: Icons.style_outlined,
      children: [
        AppSelect<String>(
          label: "Drinking",
          selectedValue: profile.drinking,
          items: AppDataConstants.drinkingOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(drinking: val)),
        ),
        AppSelect<String>(
          label: "Smoking",
          selectedValue: profile.smoking,
          items: AppDataConstants.smokingOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(smoking: val)),
        ),
        AppSelect<String>(
          label: "Exercise",
          selectedValue: profile.exercise,
          items: AppDataConstants.exerciseOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(exercise: val)),
        ),
        AppSelect<String>(
          label: "Pets",
          selectedValue: profile.pets,
          items: AppDataConstants.petOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(pets: val)),
        ),
        AppSelect<String>(
          label: "Religion",
          selectedValue: profile.religion,
          items: AppDataConstants.religionOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(religion: val)),
        ),
        AppSelect<String>(
          label: "Diet",
          selectedValue: profile.diet,
          items: AppDataConstants.dietOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(diet: val)),
        ),
      ],
    );
  }
}
