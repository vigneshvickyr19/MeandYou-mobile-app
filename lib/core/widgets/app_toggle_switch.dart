import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class AppToggleOption {
  final String label;
  final String svgPath;
  final String value;

  AppToggleOption({
    required this.label,
    required this.svgPath,
    required this.value,
  });
}

class AppToggleSwitch extends StatefulWidget {
  final String title;
  final List<AppToggleOption> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const AppToggleSwitch({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<AppToggleSwitch> createState() => _AppToggleSwitchState();
}

class _AppToggleSwitchState extends State<AppToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    int selectedIndex = widget.options.indexWhere(
      (option) => option.value == widget.selectedValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        /// Outer Container (keeps your padding, border, radius)
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.darkOverlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double optionWidth = constraints.maxWidth / widget.options.length;

              return Stack(
                children: [
                  /// Sliding Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: selectedIndex * optionWidth,
                    top: 0,
                    bottom: 0,
                    width: optionWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkOverlay.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  /// Options Row
                  Row(
                    children: widget.options.map((option) {
                      final bool isActive =
                          option.value == widget.selectedValue;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onChanged(option.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  option.svgPath,
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    isActive
                                        ? AppColors.primary
                                        : Colors.white54,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    color: isActive
                                        ? AppColors.primary
                                        : Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
