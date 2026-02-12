import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import '../constants/app_colors.dart';

/// A reusable Country Phone Input component with modern UI.
/// Supports country selection with flags, custom styling, and callbacks.
class CountryPhoneInput extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final Function(String countryCode)? onCountryChanged;
  final Function(PhoneNumber phoneNumber)? onFullNumberChanged;
  final bool showError;
  final String? errorMessage;
  final String initialCountryCode;

  const CountryPhoneInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.onCountryChanged,
    this.onFullNumberChanged,
    this.showError = false,
    this.errorMessage,
    this.initialCountryCode = 'IN',
  });

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with modern styling
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),

        // IntlPhoneField with custom decoration to match App design system
        IntlPhoneField(
          controller: controller,
          initialCountryCode: initialCountryCode,
          onChanged: onFullNumberChanged,
          onCountryChanged: (country) {
            if (onCountryChanged != null) {
              onCountryChanged!(country.dialCode);
            }
          },
          cursorColor: AppColors.primary,
          disableLengthCheck: true, // Handle validation manually/customly
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          dropdownTextStyle: const TextStyle(color: AppColors.white, fontSize: 15),
          dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
          flagsButtonPadding: const EdgeInsets.only(left: 12),
          showCountryFlag: true,
          showDropdownIcon: true,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: const Color(0xFF1A1A1A),
            countryCodeStyle: const TextStyle(color: AppColors.white),
            countryNameStyle: const TextStyle(color: AppColors.white),
            searchFieldPadding: const EdgeInsets.all(16),
            searchFieldInputDecoration: InputDecoration(
              hintText: 'Search country',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: AppColors.darkOverlay.withValues(alpha: 0.1),
              enabledBorder: _border(AppColors.darkOverlay, 1),
              focusedBorder: _border(AppColors.primary, 1.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            filled: true,
            fillColor: Colors.transparent,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: _border(AppColors.darkOverlay, 1),
            focusedBorder: _border(
              showError ? AppColors.error : AppColors.primary,
              1.8,
            ),
            errorBorder: _border(AppColors.error, 1.5),
            focusedErrorBorder: _border(AppColors.error, 1.8),
            // Hide default error text as we handle it ourselves below
            errorStyle: const TextStyle(height: 0, fontSize: 0), 
          ),
        ),

        // Custom Error Message Display
        if (showError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
