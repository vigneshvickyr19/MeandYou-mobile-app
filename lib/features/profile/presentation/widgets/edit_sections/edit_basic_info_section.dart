import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import 'edit_section_container.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../../../core/widgets/app_date_picker.dart';
import '../../../../../core/widgets/app_text_area.dart';
import 'edit_photos_grid.dart';

class EditBasicInfoSection extends StatelessWidget {
  final EditProfileController controller;

  const EditBasicInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.draftProfile!;

    return Column(
      children: [
        EditSectionContainer(
          title: "Profile Photos",
          icon: Icons.camera_alt_outlined,
          children: [
            EditPhotosGrid(controller: controller),
          ],
        ),
        const SizedBox(height: 32),
        EditSectionContainer(
          title: "Basic Information",
          icon: Icons.person_outline_rounded,
          children: [
            AppInput(
              label: "Full Name",
              hintText: "Enter your full name",
              initialValue: profile.fullName,
              onChanged: (val) =>
                  controller.updateDraft((p) => p.copyWith(fullName: val)),
            ),
            AppDatePicker(
              label: "Date of Birth${controller.age != null ? ' (Age: ${controller.age})' : ''}",
              selectedDate: profile.dob,
              onDateSelected: (date) =>
                  controller.updateDraft((p) => p.copyWith(dob: date)),
            ),
            AppTextArea(
              label: "About Me",
              hintText: "Tell people about yourself...",
              initialValue: profile.bio,
              onChanged: (val) =>
                  controller.updateDraft((p) => p.copyWith(bio: val)),
            ),
          ],
        ),
      ],
    );
  }
}
