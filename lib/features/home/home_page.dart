import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/banners/banner_section.dart';
import 'package:full_stack_e_commerce_app/features/categories/providers/subcategories_provider.dart';
import '../categories/providers/categories_provider.dart';
import '../categories/models/category.dart';
import '../categories/models/subcategory.dart';
import '../products/providers/products_provider.dart';
import '../products/widgets/product_card.dart';
import '../../core/responsive.dart';
import '../cart/cart_page.dart';
import '../orders/orders_page.dart';
import '../profile/pages/profile_page.dart';
import '../../core/app_scaffold.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int index = 0;

  Category? selectedCategory;
  SubCategory? selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    // Map nav index to pages
    late final List<Widget> pages = [
      _buildShopPage(context),
      const CartPage(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    return AppScaffold(
      currentIndex: index,
      onNavTap: (i) => setState(() => index = i),
      body: pages[index],
    );
  }

  Widget _buildShopPage(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const BannersSection(),
            const SizedBox(height: 16),

            // Categories Horizontal Scroll
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
              data: (categories) => _buildCategoriesList(categories),
            ),

            const SizedBox(height: 16),

            // Subcategories Horizontal Scroll
            if (selectedCategory != null)
              Consumer(
                builder: (context, ref, _) {
                  final subcategoriesAsync = ref.watch(
                    subCategoriesProvider(selectedCategory!.id),
                  );

                  return subcategoriesAsync.when(
                    loading: () => const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Text('Error: $err'),
                    data: (subCategories) => subCategories.isEmpty
                        ? const SizedBox()
                        : _buildSubCategoriesList(subCategories),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Products Grid (Filtered by selected subcategory)
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = selectedCategory?.id == cat.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = cat;
                selectedSubCategory = null; // reset subcategory selection
              });
            },
            child: Container(
              width: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(cat.name, textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoriesList(List<SubCategory> subCategories) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final sub = subCategories[i];
          final isSelected = selectedSubCategory?.id == sub.id;

          return GestureDetector(
            onTap: () {
              setState(() => selectedSubCategory = sub);
            },
            child: Container(
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(sub.name, textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    final subId = selectedSubCategory?.id;

    final productsAsync = ref.watch(productsProvider(subId));

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
      data: (products) {
        if (products.isEmpty)
          return const Center(child: Text('No products found'));

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        );
      },
    );
  }
}
