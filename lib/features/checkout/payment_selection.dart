import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:full_stack_e_commerce_app/features/cart/cart_provider.dart';
import 'package:full_stack_e_commerce_app/features/checkout/checkout_provider.dart';

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
    final checkout = ref.read(checkoutProvider);
    selectedPayment = checkout.paymentMethod;
  }

  String formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) return '254${phone.substring(1)}';
    if (phone.startsWith('7')) return '254$phone';
    return phone;
  }

  Future<void> payWithMpesa() async {
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final checkout = ref.read(checkoutProvider);
    final cart = ref.read(cartProvider);

    if (cart.isEmpty) {
      _toast("Cart is empty");
      return;
    }

    setState(() => isPaying = true);

    try {
      // 1️⃣ Place order and get the inserted order (with UUID)
      final insertedOrder = await checkoutNotifier.placeOrder();
      final String orderId = insertedOrder['id'];

      // 2️⃣ Compute total amount
      final amount = cart
          .fold<double>(
            0,
            (sum, item) => sum + (item.product.displayPrice * item.quantity),
          )
          .ceil();

      // 3️⃣ Format phone number
      final phone = formatPhoneNumber(checkout.phone);

      // 4️⃣ Initiate MPESA payment
      final response = await Supabase.instance.client.functions.invoke(
        'mpesa-b2b/initiate',
        body: {
          'amount': amount,
          'partyA': phone,
          'accountRef': orderId, // Use the real UUID
          'remarks': 'Payment for Order $orderId',
          'callbackUrl':
              'https://xnknxlkebtvbiauvazly.supabase.co/functions/v1/mpesa-b2b/callback',
        },
      );

      final data = response.data;

      if (data == null) throw Exception('Empty MPESA response');

      final respCode = data['ResponseCode']?.toString() ?? '-1';
      final respMsg =
          data['CustomerMessage'] ??
          data['ResponseDescription'] ??
          'Payment failed';

      if (respCode == '0') {
        _toast('MPESA prompt sent. Enter your PIN.');
      } else {
        _toast('Error: $respMsg');
      }
    } catch (e, st) {
      debugPrint('MPESA error: $e\n$st');
      _toast('Payment failed. Try again.');
    } finally {
      setState(() => isPaying = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(checkoutProvider.notifier);
    final cart = ref.watch(cartProvider);
    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.product.displayPrice * item.quantity),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('MPESA'),
          subtitle: Text('Total: Ksh ${totalAmount.toStringAsFixed(2)}'),
          leading: Radio<String>(
            value: 'MPESA',
            groupValue: selectedPayment,
            onChanged: (value) {
              setState(() => selectedPayment = value!);
              notifier.updatePayment(value!);
            },
          ),
        ),
        ListTile(
          title: const Text('Cash on Delivery'),
          subtitle: Text('Total: Ksh ${totalAmount.toStringAsFixed(2)}'),
          leading: Radio<String>(
            value: 'COD',
            groupValue: selectedPayment,
            onChanged: (value) {
              setState(() => selectedPayment = value!);
              notifier.updatePayment(value!);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (selectedPayment == 'MPESA')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPaying ? null : payWithMpesa,
              child: isPaying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Pay with MPESA'),
            ),
          ),
      ],
    );
  }
}
