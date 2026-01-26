import 'package:flutter/material.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../core/constants/app_images.dart';

class StepBasicIdentity extends StatefulWidget {
  @override
  State<StepBasicIdentity> createState() => _StepBasicIdentityState();
}

class _StepBasicIdentityState extends State<StepBasicIdentity> {
  final nameCtrl = TextEditingController();
  DateTime? dob;
  String gender = 'male';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Basic Identity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        AppInput(
          label: 'Full Name',
          hint: 'Enter your name',
          controller: nameCtrl,
        ),
        const SizedBox(height: 20),

        AppDatePicker(
          label: 'Date of Birth',
          selectedDate: dob,
          onDateSelected: (d) => setState(() => dob = d),
        ),
        const SizedBox(height: 20),

        AppToggleSwitch(
          title: 'Gender',
          selectedValue: gender,
          onChanged: (v) => setState(() => gender = v),
          options: [
            AppToggleOption(
              label: 'Male',
              value: 'male',
              svgPath: AppImages.faceMaleIcon,
            ),
            AppToggleOption(
              label: 'Female',
              value: 'female',
              svgPath: AppImages.faceFemaleIcon,
            ),
          ],
        ),
      ],
    );
  }
}
