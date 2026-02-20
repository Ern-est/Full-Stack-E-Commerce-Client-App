import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/banners/banner_section.dart';
import 'package:full_stack_e_commerce_app/features/categories/providers/subcategories_provider.dart';
import 'package:full_stack_e_commerce_app/features/home/notifications_provider.dart';
import 'package:full_stack_e_commerce_app/features/home/sections/notifications_page.dart';
import '../categories/providers/categories_provider.dart';
import '../categories/models/category.dart';
import '../categories/models/subcategory.dart';
import '../products/providers/products_provider.dart';
import '../products/models/products_params.dart';
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
  late final TextEditingController searchController;
  late final ValueNotifier<String> searchQuery;

  int index = 0;
  Category? selectedCategory;
  SubCategory? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchQuery = ValueNotifier('');
  }

  @override
  void dispose() {
    searchController.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
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
    final notifications = ref.watch(notificationsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context, notifications),

            const SizedBox(height: 16),
            const BannersSection(),
            const SizedBox(height: 16),

            /// Categories
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (categories) => _buildCategoriesList(categories),
            ),

            const SizedBox(height: 16),

            /// Subcategories
            if (selectedCategory != null)
              Consumer(
                builder: (_, ref, __) {
                  final subcategoriesAsync = ref.watch(
                    subCategoriesProvider(selectedCategory!.id),
                  );

                  return subcategoriesAsync.when(
                    loading: () => const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Text('Error: $err'),
                    data: (subs) => subs.isEmpty
                        ? const SizedBox()
                        : _buildSubCategoriesList(subs),
                  );
                },
              ),

            const SizedBox(height: 16),

            /// Products
            ValueListenableBuilder<String>(
              valueListenable: searchQuery,
              builder: (_, value, __) {
                final productsAsync = ref.watch(
                  productsProvider(
                    ProductsParams(
                      subId: selectedSubCategory?.id,
                      search: value,
                    ),
                  ),
                );

                return productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, List notifications) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Shop',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                if (notifications.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
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
                selectedSubCategory = null;
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
              setState(() {
                selectedSubCategory = sub;
              });
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
}
