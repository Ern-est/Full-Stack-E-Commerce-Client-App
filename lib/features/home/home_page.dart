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
import '../auth/providers/auth_provider.dart';

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
    final user = ref.watch(authStateProvider);
    final username = user?.userMetadata?['name'] ?? 'User';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Greeting + Notification + Search
            _buildTopBar(context, notifications, username),

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

  Widget _buildTopBar(
    BuildContext context,
    List notifications,
    String username,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting + Notification
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, $username 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B3C2F), // Gold-ish luxury
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Color(0xFF4B3C2F),
                  ),
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
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
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
        const SizedBox(height: 12),
        // Full-width Search bar
        TextField(
          controller: searchController,
          onChanged: (value) => searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFFFF9F0), // Ivory background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
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
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFFFF9F0), // Gold vs Ivory
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4B3C2F),
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFFFF9F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
              ),
              child: Text(
                sub.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4B3C2F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
