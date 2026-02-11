import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import 'edit_section_container.dart';
import '../../../../../core/widgets/app_input.dart';

class EditPersonalDetailsSection extends StatelessWidget {
  final EditProfileController controller;

  const EditPersonalDetailsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.draftProfile!;

    return EditSectionContainer(
      title: "Personal Details",
      icon: Icons.assignment_ind_outlined,
      children: [
        AppInput(
          label: "Height (cm)",
          hintText: "Enter height in cm",
          initialValue: profile.height?.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) => controller.updateDraft(
            (p) => p.copyWith(height: int.tryParse(val)),
          ),
        ),
        AppInput(
          label: "Job Title",
          hintText: "What do you do?",
          initialValue: profile.jobTitle,
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(jobTitle: val)),
        ),
        AppInput(
          label: "Education",
          hintText: "University or Degree",
          initialValue: profile.education,
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(education: val)),
        ),
        AppInput(
          label: "City",
          hintText: "Where do you live currently?",
          initialValue: profile.city,
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(city: val)),
        ),
        AppInput(
          label: "Hometown",
          hintText: "Where are you originally from?",
          initialValue: profile.hometown,
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(hometown: val)),
        ),
        AppInput(
          label: "Address",
          hintText: "Street address",
          initialValue: profile.addressLine1,
          onChanged: (val) =>
              controller.updateDraft((p) => p.copyWith(addressLine1: val)),
        ),
      ],
    );
  }
}
