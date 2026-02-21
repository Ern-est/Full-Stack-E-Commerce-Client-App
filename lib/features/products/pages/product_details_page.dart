import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/app_scaffold.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:full_stack_e_commerce_app/features/cart/cart_provider.dart';
import 'package:full_stack_e_commerce_app/features/ratings/providers/ratings_provider.dart';
import 'package:full_stack_e_commerce_app/features/ratings/widgets/write_review_sheet.dart';
import '../providers/product_details_provider.dart';
import '../providers/related_products_provider.dart';

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
    viewportFraction: 0.45,
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
        appBar: AppBar(
          title: Text(
            'Product Details',
            style: TextStyle(color: AppTheme.primaryText),
          ),
          backgroundColor: AppTheme.ivory,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryText),
        ),
        body: productAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: TextStyle(color: AppTheme.primaryText),
            ),
          ),
          data: (product) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PRODUCT GALLERY
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
                          borderRadius: BorderRadius.circular(16),
                          child: product.images.isNotEmpty
                              ? Image.network(
                                  product.images[i],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppTheme.divider.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(Icons.image, size: 80),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        child: Row(
                          children: List.generate(
                            product.images.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: activeImageIndex == i ? 12 : 8,
                              height: activeImageIndex == i ? 12 : 8,
                              decoration: BoxDecoration(
                                color: activeImageIndex == i
                                    ? AppTheme.gold
                                    : AppTheme.divider,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// TITLE & PRICE
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                if (product.hasDiscount) ...[
                  Text(
                    'Ksh ${product.finalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
                  ),
                  Text(
                    'Ksh ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ] else
                  Text(
                    'Ksh ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
                  ),
                const SizedBox(height: 16),

                /// VARIANTS
                if (product.variants.isNotEmpty) ...[
                  Text(
                    'Variants',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: product.variants.map((v) {
                      final isSelected = v == selectedVariant;
                      return ChoiceChip(
                        label: Text(
                          v,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.pureWhite
                                : AppTheme.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.gold,
                        backgroundColor: AppTheme.divider.withOpacity(0.3),
                        onSelected: (_) => setState(() => selectedVariant = v),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                /// QUANTITY
                Row(
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => setState(() {
                        if (quantity > 1) quantity--;
                      }),
                      icon: Icon(Icons.remove, color: AppTheme.primaryText),
                    ),
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: Icon(Icons.add, color: AppTheme.primaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// DESCRIPTION
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'No description available.',
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                ),
                const SizedBox(height: 24),

                /// RATINGS SECTION
                Consumer(
                  builder: (context, ref, _) {
                    final statsAsync = ref.watch(
                      productRatingStatsProvider(product.id),
                    );
                    final reviewsAsync = ref.watch(
                      productReviewsProvider(product.id),
                    );

                    return statsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                      data: (stats) {
                        final avg = (stats['average'] ?? 0).toDouble();
                        final total = stats['total'] ?? 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  avg.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < avg.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.gold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "($total reviews)",
                                  style: TextStyle(
                                    color: AppTheme.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            ...["five", "four", "three", "two", "one"].map((
                              key,
                            ) {
                              final count = stats[key] ?? 0;
                              final percent = total == 0 ? 0.0 : count / total;
                              final star = key == "five"
                                  ? 5
                                  : key == "four"
                                  ? 4
                                  : key == "three"
                                  ? 3
                                  : key == "two"
                                  ? 2
                                  : 1;

                              return Row(
                                children: [
                                  Text(
                                    "$star⭐",
                                    style: TextStyle(
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      backgroundColor: AppTheme.divider
                                          .withOpacity(0.3),
                                      color: AppTheme.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$count",
                                    style: TextStyle(
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                ],
                              );
                            }),

                            const SizedBox(height: 16),

                            reviewsAsync.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const SizedBox(),
                              data: (reviews) {
                                if (reviews.isEmpty)
                                  return Text(
                                    "No reviews yet.",
                                    style: TextStyle(
                                      color: AppTheme.secondaryText,
                                    ),
                                  );
                                return Column(
                                  children: reviews
                                      .take(3)
                                      .map(
                                        (r) => Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.pureWhite,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (i) => Icon(
                                                    i < r.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: AppTheme.gold,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (r.clientName != null)
                                                Text(
                                                  r.clientName!,
                                                  style: TextStyle(
                                                    color: AppTheme.primaryText,
                                                  ),
                                                ),
                                              if (r.comment != null)
                                                Text(
                                                  r.comment!,
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.secondaryText,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppTheme.ivory,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    builder: (_) =>
                                        WriteReviewSheet(productId: product.id),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.gold,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text("Write Review"),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    );
                  },
                ),

                /// ADD TO CART
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
                      backgroundColor: product.inStock
                          ? AppTheme.gold
                          : AppTheme.divider,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: Text(
                      product.inStock ? 'Add to Cart' : 'Out of Stock',
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// RELATED PRODUCTS
                Text(
                  'Related Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, _) {
                    final relatedAsync = ref.watch(
                      relatedProductsProvider(product.subcategoryId ?? ''),
                    );

                    return relatedAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text(
                        'Error: $err',
                        style: TextStyle(color: AppTheme.primaryText),
                      ),
                      data: (relatedProducts) {
                        if (relatedProducts.isEmpty) {
                          return Text(
                            'No related products',
                            style: TextStyle(color: AppTheme.secondaryText),
                          );
                        }

                        return SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _relatedController,
                            padEnds: false,
                            itemCount: relatedProducts.length,
                            itemBuilder: (_, i) {
                              final p = relatedProducts[i];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: p.images.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(16),
                                                  ),
                                              child: Image.network(
                                                p.images.first,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.image),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppTheme.primaryText,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ksh ${p.hasDiscount ? p.finalPrice : p.price}',
                                            style: TextStyle(
                                              color: AppTheme.gold,
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
