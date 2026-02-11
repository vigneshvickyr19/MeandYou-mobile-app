import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/app_colors.dart';

class AppSelect<T> extends StatefulWidget {
  final String label;
  final T? selectedValue;
  final String hintText;
  final bool showError;
  final String? errorMessage;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppSelect({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hintText = 'Select',
    this.showError = false,
    this.errorMessage,
  });

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false; // Track dropdown state

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color borderColor() {
    if (widget.showError) return AppColors.error;
    if (_focusNode.hasFocus || _isOpen) return AppColors.primary;
    return AppColors.darkOverlay;
  }

  double borderWidth() {
    if (widget.showError || _focusNode.hasFocus || _isOpen) return 1.8;
    return 1;
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

        // Dropdown Field
        Focus(
          focusNode: _focusNode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor(), width: borderWidth()),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: widget.selectedValue,
                hint: Text(
                  widget.hintText,
                  style: const TextStyle(color: Colors.white24, fontSize: 14),
                ),
                icon: AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0, // Rotate arrow when open
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
                items: widget.items,
                onChanged: (value) {
                  widget.onChanged(value);
                  setState(() {}); // Refresh field
                },
                onTap: () {
                  setState(() {
                    _isOpen = !_isOpen; // Toggle dropdown state
                  });
                },
                dropdownColor: AppColors.black,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
            ),
          ),
        ),

        // Error Message
        if (widget.showError && widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: FadeInLeft(
              duration: const Duration(milliseconds: 300),
              from: 10,
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
