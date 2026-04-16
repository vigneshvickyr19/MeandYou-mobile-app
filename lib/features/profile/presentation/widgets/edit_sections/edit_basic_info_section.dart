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
            _BioSection(controller: controller),
          ],
        ),
      ],
    );
  }
}

class _BioSection extends StatefulWidget {
  final EditProfileController controller;
  const _BioSection({required this.controller});

  @override
  State<_BioSection> createState() => _BioSectionState();
}

class _BioSectionState extends State<_BioSection> {
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.controller.draftProfile?.bio ?? "";
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Expanded(
               child: AppTextArea(
                label: "About Me",
                hintText: "Tell people about yourself...",
                controller: _bioController,
                onChanged: (val) =>
                    widget.controller.updateDraft((p) => p.copyWith(bio: val)),
                           ),
             ),
          ],
        ),
      ],
    );
  }
}
