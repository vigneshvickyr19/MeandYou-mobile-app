import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class AppToggleOption {
  final String label;
  final String value;
  final String? svgPath;

  const AppToggleOption({
    required this.label,
    required this.value,
    this.svgPath,
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
    final selectedIndex = widget.options.indexWhere(
      (o) => o.value == widget.selectedValue,
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

        /// Toggle Container
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.darkOverlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final optionWidth = constraints.maxWidth / widget.options.length;

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
                        color: AppColors.darkOverlay.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  /// Options
                  Row(
                    children: widget.options.map((option) {
                      final isActive = option.value == widget.selectedValue;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onChanged(option.value),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /// ✅ ICON (only if provided)
                                if (option.svgPath != null) ...[
                                  SvgPicture.asset(
                                    option.svgPath!,
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
                                ],

                                /// Text
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
