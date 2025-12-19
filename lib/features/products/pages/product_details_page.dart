import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/app_scaffold.dart';
import 'package:full_stack_e_commerce_app/features/cart/cart_provider.dart';
import '../providers/product_details_provider.dart';
import '../providers/related_products_provider.dart';

// ... (imports remain unchanged)
// ... (imports remain unchanged)

class ProductDetailsPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int quantity = 1;
  String selectedVariant = 'Default';

  int activeImageIndex = 0;
  final PageController _galleryController = PageController();
  final PageController _relatedController = PageController(
    viewportFraction: 0.4,
  );

  @override
  void dispose() {
    _galleryController.dispose();
    _relatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));

    return AppScaffold(
      currentIndex: 0,
      onNavTap: (_) {},
      body: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: productAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (product) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Gallery
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _galleryController,
                        itemCount: product.images.length,
                        onPageChanged: (index) =>
                            setState(() => activeImageIndex = index),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.images.isNotEmpty
                              ? Image.network(
                                  product.images[i],
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                )
                              : Container(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: Icon(Icons.image, size: 80),
                                  ),
                                ),
                        ),
                      ),
                      // Indicator
                      Positioned(
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(product.images.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: activeImageIndex == i ? 12 : 8,
                              height: activeImageIndex == i ? 12 : 8,
                              decoration: BoxDecoration(
                                color: activeImageIndex == i
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Price
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ksh ${product.displayPrice}', // ✅ Dollar replaced with Ksh
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),

                // Variants
                if (product.variants.isNotEmpty) ...[
                  const Text('Variants', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: product.variants.map((v) {
                      final isSelected = v == selectedVariant;
                      return ChoiceChip(
                        label: Text(v),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selectedVariant = v),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quantity Selector
                Row(
                  children: [
                    const Text('Quantity', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => setState(() {
                        if (quantity > 1) quantity--;
                      }),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Description', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(product.description ?? 'No description available.'),
                const SizedBox(height: 24),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.inStock
                        ? () {
                            ref
                                .read(cartProvider.notifier)
                                .addToCart(product, quantity, selectedVariant);
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$quantity x ${product.name} added to cart',
                                ),
                                duration: const Duration(milliseconds: 800),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      product.inStock ? 'Add to Cart' : 'Out of Stock',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Related Products Carousel
                const Text(
                  'Related Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final relatedAsync = ref.watch(
                      relatedProductsProvider(product.subcategoryId ?? ''),
                    );
                    return relatedAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (relatedProducts) {
                        if (relatedProducts.isEmpty)
                          return const Text('No related products');
                        return SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _relatedController,
                            itemCount: relatedProducts.length,
                            padEnds: false,
                            pageSnapping: true,
                            itemBuilder: (_, i) {
                              final p = relatedProducts[i];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                        ),
                                        child: p.images.isNotEmpty
                                            ? Image.network(
                                                p.images.first,
                                                fit: BoxFit.cover,
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 40,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(
                                            p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ksh ${p.displayPrice}', // ✅ Dollar replaced with Ksh
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
