import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../../../core/responsive.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';
import '../models/category.dart';
import '../pages/subcategories_page.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: AppTheme.luxuryTheme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              'Error: $err',
              style: TextStyle(color: AppTheme.primaryText),
            ),
            data: (categories) => _buildCategories(context, categories),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<Category> categories) {
    final isDesktop = Responsive.isDesktop(context);

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final category = categories[i];

          return SizedBox(
            width: isDesktop ? 220 : 150,
            child: CategoryCard(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubCategoriesPage(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
