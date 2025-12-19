import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/categories/pages/subcategories_page.dart';
import '../../../core/responsive.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';
import '../models/category.dart';

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
          const Text(
            'Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (categories) => _buildCategories(context, categories),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<Category> categories) {
    final isDesktop = Responsive.isDesktop(context);

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final category = categories[i];

          return SizedBox(
            width: isDesktop ? 220 : 140, // wider on desktop
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
