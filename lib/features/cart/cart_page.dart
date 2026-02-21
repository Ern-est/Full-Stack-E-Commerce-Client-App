import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:full_stack_e_commerce_app/features/checkout/checkout_page.dart';
import '../cart/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    final totalPrice = cart.fold<double>(
      0,
      (sum, item) => sum + (item.product.finalPrice * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryText),
        titleTextStyle: AppTheme.luxuryTheme.textTheme.titleLarge,
      ),
      body: cart.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final product = item.product;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.goldTint,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: product.mainImage != null
                                ? Image.network(
                                    product.mainImage!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              color: AppTheme.primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Variant: ${item.selectedVariant}',
                                style: const TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (product.hasDiscount) ...[
                                Text(
                                  'Ksh ${product.finalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.goldDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Ksh ${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryText,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else
                                Text(
                                  'Ksh ${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.goldDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: AppTheme.primaryText,
                                  ),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      ref
                                          .read(cartProvider.notifier)
                                          .addToCart(
                                            product,
                                            -1,
                                            item.selectedVariant,
                                          );
                                    } else {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeFromCart(
                                            product.id,
                                            item.selectedVariant,
                                          );
                                    }
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppTheme.primaryText,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addToCart(
                                          product,
                                          1,
                                          item.selectedVariant,
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// Total & Checkout Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.ivory,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: Ksh ${totalPrice.toStringAsFixed(2)}',
                        style: AppTheme.luxuryTheme.textTheme.headlineMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: AppTheme.primaryText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
