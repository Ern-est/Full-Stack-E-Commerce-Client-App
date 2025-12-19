import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/cart/cart_provider.dart';
import 'package:full_stack_e_commerce_app/features/checkout/checkout_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    // ✅ Calculate total price dynamically
    final totalPrice = cart.fold<double>(
      0,
      (sum, item) => sum + (item.product.displayPrice * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: item.product.mainImage != null
                              ? Image.network(
                                  item.product.mainImage!,
                                  width: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, color: Colors.white),
                          title: Text(
                            item.product.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Variant: ${item.selectedVariant}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Price: Ksh ${item.product.displayPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
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
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      ref
                                          .read(cartProvider.notifier)
                                          .addToCart(
                                            item.product,
                                            -1,
                                            item.selectedVariant,
                                          );
                                    } else {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeFromCart(
                                            item.product.id,
                                            item.selectedVariant,
                                          );
                                    }
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addToCart(
                                          item.product,
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: Ksh ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
