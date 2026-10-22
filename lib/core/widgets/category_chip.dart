import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../enums/news_category.dart';

class CategoryChips extends StatelessWidget {
  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: NewsCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = NewsCategory.values[index];
          final isSelected = category == selected;

          return ChoiceChip(
            label: Text(category.label),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppTheme.primaryColor,
            backgroundColor: AppTheme.cardColor,
            side: const BorderSide(color: AppTheme.borderColor),
            labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}