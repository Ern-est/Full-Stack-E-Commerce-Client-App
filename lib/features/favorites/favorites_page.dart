import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/features/favorites/favorite_item.dart';
import '../categories/product_list_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favorites = List.generate(
      6,
      (i) => {'name': 'Product ${i + 1}', 'price': 99.99 + i * 10},
    );

    int columns = 2;
    final width = MediaQuery.of(context).size.width;
    if (width > 600 && width <= 1024) columns = 3; // tablet
    if (width > 1024) columns = 5; // desktop

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (_, i) {
                  final item = favorites[i];
                  return FavoriteItem(
                    name: item['name'],
                    price: item['price'],
                    onTap: () {
                      // Navigate to product details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductListPage(subcategoryName: item['name']),
                        ),
                      );
                    },
                    onRemove: () {
                      // TODO: remove from favorites
                    },
                  );
                },
              ),
            ),
    );
  }
}
