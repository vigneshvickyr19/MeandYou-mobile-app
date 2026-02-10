import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool showError;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final TextInputType? keyboardType;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.showError = false,
    this.errorMessage,
    this.onChanged,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

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
          widget.label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),

        // Input Field
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType, // ✅ USE IT HERE
          cursorColor: AppColors.primary,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
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
              widget.showError ? AppColors.error : AppColors.primary,
              1.8,
            ),
            errorBorder: _border(AppColors.error, 1.5),
            focusedErrorBorder: _border(AppColors.error, 1.8),

            suffixIcon: widget.isPassword
                ? IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),

        if (widget.showError && widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorMessage!,
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
