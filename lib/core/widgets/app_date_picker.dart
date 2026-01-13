import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';

class AppDatePicker extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final String hint;
  final bool showError;
  final String? errorMessage;
  final ValueChanged<DateTime> onDateSelected;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.hint = 'DD/MM/YYYY',
    this.showError = false,
    this.errorMessage,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Future<void> _pickDate() async {
    _focusNode.requestFocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.black,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    _focusNode.unfocus();

    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    final String text = widget.selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!)
        : widget.hint;

    Color borderColor() {
      if (widget.showError) return AppColors.error;
      if (isFocused) return AppColors.primary;
      return AppColors.darkOverlay;
    }

    double borderWidth() {
      if (widget.showError || isFocused) return 1.8;
      return 1;
    }

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

        // Date Field
        GestureDetector(
          onTap: _pickDate,
          child: Focus(
            focusNode: _focusNode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor(), width: borderWidth()),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.selectedDate != null
                            ? AppColors.white
                            : Colors.white54,
                      ),
                    ),
                  ),
                  // Use SVG Icon
                  SvgPicture.asset(
                    AppImages.calendarIcon,
                    width: 20,
                    height: 20,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
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
