import 'package:flutter/material.dart';
import '../../../../core/widgets/app_input.dart';

class StepAboutMe extends StatelessWidget {
  final bioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'About Me',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 24),

        AppInput(
          label: 'Short Bio',
          hint: 'Tell something about you',
          controller: bioCtrl,
        ),
      ],
    );
  }
}
