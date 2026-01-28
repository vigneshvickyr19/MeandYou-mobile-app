import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InterestItem {
  final String label;
  final IconData icon;

  InterestItem({required this.label, required this.icon});
}

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
  final List<InterestItem> _items = [
    InterestItem(label: 'Game', icon: Icons.sports_esports),
    InterestItem(label: 'Singing', icon: Icons.mic),
    InterestItem(label: 'Yoga', icon: Icons.self_improvement),
    InterestItem(label: 'Anime', icon: Icons.favorite),
    InterestItem(label: 'Movie', icon: Icons.movie),
    InterestItem(label: 'Coffee', icon: Icons.coffee),
    InterestItem(label: 'Music', icon: Icons.music_note),
    InterestItem(label: 'Travel', icon: Icons.flight),
    InterestItem(label: 'Fitness', icon: Icons.fitness_center),
    InterestItem(label: 'Reading', icon: Icons.menu_book),
  ];

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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _items.map((item) {
        final isSelected = _selected.contains(item.label);

        return GestureDetector(
          onTap: () => _toggle(item.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.darkOverlay : AppColors.black,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.greyDark,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
