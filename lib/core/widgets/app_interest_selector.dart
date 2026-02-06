import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_data_constants.dart';

class AppInterestSelector extends StatefulWidget {
  final List<String> selectedInterests;
  final ValueChanged<List<String>> onChanged;

  const AppInterestSelector({
    super.key,
    required this.selectedInterests,
    required this.onChanged,
  });

  @override
  State<AppInterestSelector> createState() => _AppInterestSelectorState();
}

class _AppInterestSelectorState extends State<AppInterestSelector> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedInterests);
  }

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
    widget.onChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          children: AppDataConstants.interests.map((item) {
            final isSelected = _selected.contains(item.label);

            return InkWell(
              onTap: () => _toggle(item.label),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16,
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
