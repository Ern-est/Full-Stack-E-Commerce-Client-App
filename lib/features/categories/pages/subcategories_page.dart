import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/categories/widgets/subcategory_card.dart';
import '../models/category.dart';
import '../providers/subcategories_provider.dart'; // you'll create this

class SubCategoriesPage extends ConsumerWidget {
  final Category category;

  const SubCategoriesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch subcategories for this category
    final subcategoriesAsync = ref.watch(subCategoriesProvider(category.id));

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: subcategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (subcategories) {
          if (subcategories.isEmpty) {
            return const Center(child: Text('No subcategories found'));
          }
          return SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subcategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final sub = subcategories[i];
                return SubCategoryCard(
                  subCategory: sub,
                  onTap: () {
                    // Navigate to filtered products page
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
