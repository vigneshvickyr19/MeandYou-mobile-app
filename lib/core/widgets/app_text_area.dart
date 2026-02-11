import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextArea extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final int minLines;
  final int maxLines;
  final bool showError;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;

  const AppTextArea({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.minLines = 3,
    this.maxLines = 6,
    this.showError = false,
    this.errorMessage,
    this.onChanged,
  });

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(AppTextArea oldWidget) {
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

        // TextArea
        TextField(
          controller: _effectiveController,
          onChanged: widget.onChanged,
          cursorColor: AppColors.primary,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
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
          ),
        ),

        // Error Message
        if (widget.showError && widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
