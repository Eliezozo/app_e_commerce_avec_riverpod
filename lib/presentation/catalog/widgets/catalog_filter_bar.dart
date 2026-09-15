import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/catalog_filter.dart';
import '../../../providers/catalog_filter_provider.dart';
import '../../../providers/product_providers.dart';

class CatalogFilterBar extends ConsumerWidget {
  const CatalogFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);
    final categories = ref.watch(productCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: ref.read(catalogFilterProvider.notifier).setQuery,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryChip(
                  label: AppStrings.allCategories,
                  selected: filter.category == null,
                  onTap: () =>
                      ref.read(catalogFilterProvider.notifier).setCategory(null),
                );
              }
              final category = categories[index - 1];
              return _CategoryChip(
                label: category,
                selected: filter.category == category,
                onTap: () =>
                    ref.read(catalogFilterProvider.notifier).setCategory(category),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Text(
                AppStrings.sortLabel,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const Spacer(),
              DropdownButtonHideUnderline(
                child: DropdownButton<ProductSort>(
                  value: filter.sort,
                  dropdownColor: AppColors.surfaceAlt,
                  iconEnabledColor: AppColors.textSecondary,
                  style: const TextStyle(color: AppColors.textSecondary),
                  items: ProductSort.values
                      .map(
                        (sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(labelForSort(sort)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (sort) {
                    if (sort == null) return;
                    ref.read(catalogFilterProvider.notifier).setSort(sort);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
