import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Your Location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Where in the world are you located?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: AppInput(
              label: 'Address Line 1',
              hintText: 'Street, Building, Flat...',
              controller: address1Ctrl,
              showError: profileProvider.errors.containsKey('addressLine1'),
              errorMessage: profileProvider.errors['addressLine1'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(addressLine1: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: AppInput(
              label: 'City',
              hintText: 'e.g. New York',
              controller: cityCtrl,
              showError: profileProvider.errors.containsKey('city'),
              errorMessage: profileProvider.errors['city'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(city: v)),
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'State',
                    hintText: 'NY',
                    controller: stateCtrl,
                    showError: profileProvider.errors.containsKey('state'),
                    errorMessage: profileProvider.errors['state'],
                    onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(state: v)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'Pin Code',
                    hintText: '10001',
                    controller: pinCodeCtrl,
                    showError: profileProvider.errors.containsKey('pinCode'),
                    errorMessage: profileProvider.errors['pinCode'],
                    keyboardType: TextInputType.number,
                    onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(pinCode: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: AppInput(
              label: 'Country',
              hintText: 'e.g. United States',
              controller: countryCtrl,
              showError: profileProvider.errors.containsKey('country'),
              errorMessage: profileProvider.errors['country'],
              onChanged: (v) => profileProvider.updateProfile((p) => p.copyWith(country: v)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
