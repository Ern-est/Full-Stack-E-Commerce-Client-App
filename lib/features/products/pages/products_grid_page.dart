import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../providers/products_provider.dart';
import '../models/products_params.dart';
import '../widgets/product_card.dart';

class ProductsGridPage extends ConsumerWidget {
  final String? subcategoryId;

  const ProductsGridPage({super.key, this.subcategoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      productsProvider(ProductsParams(subId: subcategoryId, search: '')),
    );

    int crossAxis = 2;
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      crossAxis = 5;
    } else if (width > 800)
      // ignore: curly_braces_in_flow_control_structures
      crossAxis = 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              );
            }

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxis,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, i) => ProductCard(product: products[i]),
            );
          },
        ),
      ),
    );
  }
}
