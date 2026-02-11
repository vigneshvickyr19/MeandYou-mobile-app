import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import 'edit_section_container.dart';
import '../../../../../core/widgets/app_interest_selector.dart';

class EditInterestsSection extends StatelessWidget {
  final EditProfileController controller;

  const EditInterestsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.draftProfile!;

    return EditSectionContainer(
      title: "Interests",
      icon: Icons.favorite_outline_rounded,
      children: [
        AppInterestSelector(
          selectedInterests: profile.interests ?? [],
          onChanged: (interests) =>
              controller.updateDraft((p) => p.copyWith(interests: interests)),
        ),
      ],
    );
  }
}
