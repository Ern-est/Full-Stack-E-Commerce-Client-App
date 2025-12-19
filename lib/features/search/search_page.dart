import 'package:flutter/material.dart';
import 'filter_panel.dart';
import '../categories/product_list_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  String selectedCategory = 'All';
  double maxPrice = 500;
  int minRating = 0;

  final List<Map<String, dynamic>> products = List.generate(
    12,
    (i) => {
      'name': 'Product ${i + 1}',
      'price': 50 + i * 10,
      'rating': i % 5 + 1,
    },
  );

  @override
  Widget build(BuildContext context) {
    int columns = 2;
    final width = MediaQuery.of(context).size.width;
    if (width > 600 && width <= 1024) columns = 3; // tablet
    if (width > 1024) columns = 5; // desktop

    // Filter products
    final filtered = products.where((p) {
      final matchesQuery = p['name'].toLowerCase().contains(
        query.toLowerCase(),
      );
      final matchesCategory =
          selectedCategory == 'All' || p['category'] == selectedCategory;
      final matchesPrice = p['price'] <= maxPrice;
      final matchesRating = p['rating'] >= minRating;
      return matchesQuery && matchesCategory && matchesPrice && matchesRating;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            TextField(
              onChanged: (val) => setState(() => query = val),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Panel
            FilterPanel(
              selectedCategory: selectedCategory,
              maxPrice: maxPrice,
              minRating: minRating,
              onFilterChange: (cat, price, rating) {
                setState(() {
                  selectedCategory = cat;
                  maxPrice = price;
                  minRating = rating;
                });
              },
            ),
            const SizedBox(height: 12),

            // Products Grid
            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (_, i) {
                  final product = filtered[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductListPage(subcategoryName: product['name']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(product['name']),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${product['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
