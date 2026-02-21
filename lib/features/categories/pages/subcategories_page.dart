import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../models/category.dart';
import '../widgets/subcategory_card.dart';
import '../providers/subcategories_provider.dart';

class SubCategoriesPage extends ConsumerWidget {
  final Category category;

  const SubCategoriesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(subCategoriesProvider(category.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.name,
          style: AppTheme.luxuryTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: subcategoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: TextStyle(color: AppTheme.primaryText),
            ),
          ),
          data: (subcategories) {
            if (subcategories.isEmpty) {
              return Center(
                child: Text(
                  'No subcategories found',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              );
            }

            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: subcategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final sub = subcategories[i];
                  return SizedBox(
                    width: 150,
                    child: SubCategoryCard(
                      subCategory: sub,
                      onTap: () {
                        // Navigate to filtered products page
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
