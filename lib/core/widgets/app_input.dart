import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_colors.dart';

class AppInput extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool showError;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final TextInputType? keyboardType;

  const AppInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
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
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _effectiveController.dispose();
      }
      _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
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
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Input Field
        TextField(
          controller: _effectiveController,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          cursorColor: AppColors.primary,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            enabledBorder: _border(Colors.white.withValues(alpha: 0.08), 1),
            focusedBorder: _border(
              widget.showError ? AppColors.error : AppColors.primary,
              1.5,
            ),
            errorBorder: _border(AppColors.error.withValues(alpha: 0.5), 1),
            focusedErrorBorder: _border(AppColors.error, 1.5),

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
            child: FadeInLeft(
              duration: const Duration(milliseconds: 300),
              from: 10,
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
