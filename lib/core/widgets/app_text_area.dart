import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextArea extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final bool showError;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;

  const AppTextArea({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.minLines = 3,
    this.maxLines = 6,
    this.showError = false,
    this.errorMessage,
    this.onChanged,
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
        // Label
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

        // TextArea
        TextField(
          controller: controller,
          onChanged: onChanged,
          cursorColor: AppColors.primary,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            filled: true,
            fillColor: Colors.transparent,
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
          ),
        ),

        // Error Message
        if (showError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
