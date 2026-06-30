import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterBar<T> extends StatelessWidget {
  final List<(String, T)> options;
  final T selected;
  final ValueChanged<T> onSelect;

  const FilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          for (final (label, value) in options)
            FilterChipButton(
              label: label,
              selected: selected == value,
              onTap: () => onSelect(value),
            ),
        ],
      ),
    );
  }
}
