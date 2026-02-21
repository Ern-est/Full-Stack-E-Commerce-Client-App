import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../cart/cart_provider.dart';
import 'checkout_provider.dart';

class PaymentSelection extends ConsumerStatefulWidget {
  const PaymentSelection({super.key});

  @override
  ConsumerState<PaymentSelection> createState() => _PaymentSelectionState();
}

class _PaymentSelectionState extends ConsumerState<PaymentSelection> {
  late String selectedPayment;
  bool isPaying = false;

  @override
  void initState() {
    super.initState();
    selectedPayment = ref.read(checkoutProvider).paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(checkoutProvider.notifier);
    final cart = ref.watch(cartProvider);

    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.product.finalPrice * item.quantity),
    );

    final bool isCartEmpty = cart.isEmpty;

    return Card(
      elevation: 3,
      color: AppTheme.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total: Ksh ${totalAmount.toStringAsFixed(2)}',
              style: AppTheme.luxuryTheme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('MPESA', isCartEmpty, notifier),
            _buildRadioOption('Cash on Delivery', isCartEmpty, notifier),
            const SizedBox(height: 20),
            if (selectedPayment == 'MPESA')
              ElevatedButton(
                onPressed: (isPaying || isCartEmpty) ? null : () {},
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
                child: isPaying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay with MPESA'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value, bool isCartEmpty, notifier) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(value, style: const TextStyle(color: AppTheme.primaryText)),
      leading: Radio<String>(
        value: value,
        groupValue: selectedPayment,
        onChanged: (v) {
          if (v == null) return;
          setState(() => selectedPayment = v);
          notifier.updatePayment(v);
        },
        activeColor: AppTheme.gold,
      ),
    );
  }
}
