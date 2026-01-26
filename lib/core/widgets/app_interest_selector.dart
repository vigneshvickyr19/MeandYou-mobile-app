import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InterestItem {
  final String label;
  final IconData icon;

  InterestItem({required this.label, required this.icon});
}

class InterestChipSelector extends StatefulWidget {
  final ValueChanged<List<String>> onSelectionChanged;

  const InterestChipSelector({super.key, required this.onSelectionChanged});

  @override
  State<InterestChipSelector> createState() => _InterestChipSelectorState();
}

class _InterestChipSelectorState extends State<InterestChipSelector> {
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

  final Set<String> _selected = {};

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
    widget.onSelectionChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          final isSelected = _selected.contains(item.label);

          return GestureDetector(
            onTap: () => _toggle(item.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greyDark,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
