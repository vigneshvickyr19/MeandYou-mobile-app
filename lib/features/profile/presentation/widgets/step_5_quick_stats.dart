import 'package:flutter/material.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_select.dart';

class StepQuickStats extends StatefulWidget {
  @override
  State<StepQuickStats> createState() => _StepQuickStatsState();
}

class _StepQuickStatsState extends State<StepQuickStats> {
  final heightCtrl = TextEditingController();

  String? jobTitle;
  String? company;
  String? education;
  String? hometown;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lorem ipsum dolor sit amet consectetur proin habitasse lacus senectus bibendum nibh egestas.',
          style: TextStyle(color: Colors.white60),
        ),

        const SizedBox(height: 24),

        /// Height
        AppInput(
          label: 'Height in cm',
          hint: '175',
          controller: heightCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),

        /// Job Title
        AppSelect<String>(
          label: 'Job Title',
          hint: 'Select job title',
          selectedValue: jobTitle,
          items: const [
            DropdownMenuItem(value: 'Designer', child: Text('Designer')),
            DropdownMenuItem(value: 'Developer', child: Text('Developer')),
            DropdownMenuItem(
              value: 'Product Manager',
              child: Text('Product Manager'),
            ),
          ],
          onChanged: (v) => setState(() => jobTitle = v),
        ),
        const SizedBox(height: 20),

        /// Company Name
        AppSelect<String>(
          label: 'Company Name',
          hint: 'Select company',
          selectedValue: company,
          items: const [
            DropdownMenuItem(
              value: 'Designer Studio Pvt. Ltd.',
              child: Text('Designer Studio Pvt. Ltd.'),
            ),
            DropdownMenuItem(
              value: 'Tech Solutions Pvt. Ltd.',
              child: Text('Tech Solutions Pvt. Ltd.'),
            ),
          ],
          onChanged: (v) => setState(() => company = v),
        ),
        const SizedBox(height: 20),

        /// Education
        AppSelect<String>(
          label: 'Education',
          hint: 'Select education',
          selectedValue: education,
          items: const [
            DropdownMenuItem(value: 'UG', child: Text('UG')),
            DropdownMenuItem(value: 'PG', child: Text('PG')),
            DropdownMenuItem(value: 'PhD', child: Text('PhD')),
          ],
          onChanged: (v) => setState(() => education = v),
        ),
        const SizedBox(height: 20),

        /// Hometown
        AppSelect<String>(
          label: 'Hometown',
          hint: 'Select hometown',
          selectedValue: hometown,
          items: const [
            DropdownMenuItem(value: 'Chennai', child: Text('Chennai')),
            DropdownMenuItem(value: 'Bangalore', child: Text('Bangalore')),
            DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
          ],
          onChanged: (v) => setState(() => hometown = v),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
