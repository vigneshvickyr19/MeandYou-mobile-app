import 'package:flutter/material.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_select.dart';

class StepLocation extends StatefulWidget {
  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  final addressLine1 = TextEditingController();
  final addressLine2 = TextEditingController();
  final pinCode = TextEditingController();

  String? city;
  String? state;
  String? country;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'Location Details',
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

        /// Address Line 1
        AppInput(
          label: 'Address Line 1',
          hint: 'House / Street name',
          controller: addressLine1,
        ),
        const SizedBox(height: 20),

        /// Address Line 2
        AppInput(
          label: 'Address Line 2',
          hint: 'Area / Landmark',
          controller: addressLine2,
        ),
        const SizedBox(height: 20),

        /// City & State
        Row(
          children: [
            Expanded(
              child: AppSelect<String>(
                label: 'City',
                hint: 'Select city',
                selectedValue: city,
                items: const [
                  DropdownMenuItem(value: 'Chennai', child: Text('Chennai')),
                  DropdownMenuItem(
                    value: 'Bangalore',
                    child: Text('Bangalore'),
                  ),
                  DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                ],
                onChanged: (v) => setState(() => city = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSelect<String>(
                label: 'State',
                hint: 'Select state',
                selectedValue: state,
                items: const [
                  DropdownMenuItem(
                    value: 'Tamil Nadu',
                    child: Text('Tamil Nadu'),
                  ),
                  DropdownMenuItem(
                    value: 'Karnataka',
                    child: Text('Karnataka'),
                  ),
                  DropdownMenuItem(
                    value: 'Maharashtra',
                    child: Text('Maharashtra'),
                  ),
                ],
                onChanged: (v) => setState(() => state = v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// Country & Pin Code
        Row(
          children: [
            Expanded(
              child: AppSelect<String>(
                label: 'Country',
                hint: 'Select country',
                selectedValue: country,
                items: const [
                  DropdownMenuItem(value: 'India', child: Text('India')),
                  DropdownMenuItem(value: 'USA', child: Text('USA')),
                ],
                onChanged: (v) => setState(() => country = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInput(
                label: 'Pin Code',
                hint: '600000',
                controller: pinCode,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
