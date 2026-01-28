import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepLocation extends StatefulWidget {
  const StepLocation({super.key});

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  late TextEditingController address1Ctrl;
  late TextEditingController address2Ctrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController countryCtrl;
  late TextEditingController pinCodeCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileSetupProvider>(context, listen: false).draftProfile;
    address1Ctrl = TextEditingController(text: p?.addressLine1 ?? '');
    address2Ctrl = TextEditingController(text: p?.addressLine2 ?? '');
    cityCtrl = TextEditingController(text: p?.city ?? '');
    stateCtrl = TextEditingController(text: p?.state ?? '');
    countryCtrl = TextEditingController(text: p?.country ?? '');
    pinCodeCtrl = TextEditingController(text: p?.pinCode ?? '');
  }

  @override
  void dispose() {
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    pinCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);

    return ListView(
      children: [
        const Text(
          'Location Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AppInput(
          label: 'Address Line 1',
          hint: 'Enter address 1',
          controller: address1Ctrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(addressLine1: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Address Line 2 (Optional)',
          hint: 'Enter address 2',
          controller: address2Ctrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(addressLine2: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'City',
          hint: 'Enter city',
          controller: cityCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(city: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'State',
          hint: 'Enter state',
          controller: stateCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(state: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Country',
          hint: 'Enter country',
          controller: countryCtrl,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(country: v)),
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Pin Code',
          hint: 'Enter pin code',
          controller: pinCodeCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(pinCode: v)),
        ),
      ],
    );
  }
}
