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
  RealtimeChannel? orderChannel;

  @override
  void initState() {
    super.initState();
    final checkout = ref.read(checkoutProvider);
    selectedPayment = checkout.paymentMethod;
  }

  @override
  void dispose() {
    orderChannel?.unsubscribe();
    super.dispose();
  }

  String formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) return '254${phone.substring(1)}';
    if (phone.startsWith('7')) return '254$phone';
    return phone;
  }

  Future<String?> showPhoneDialog(double amount) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter MPESA Phone"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "07XXXXXXXX"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text("Pay Ksh ${amount.toStringAsFixed(0)}"),
          ),
        ],
      ),
    );
  }

  Future<void> payWithMpesa() async {
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final cart = ref.read(cartProvider);

    if (cart.isEmpty) {
      _toast("Cart is empty");
      return;
    }

    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.product.displayPrice * item.quantity),
    );

    final phoneInput = await showPhoneDialog(totalAmount);
    if (phoneInput == null || phoneInput.isEmpty) return;

    final formattedPhone = formatPhoneNumber(phoneInput);

    setState(() => isPaying = true);

    try {
      // 1️⃣ Place the order
      final insertedOrder = await checkoutNotifier.placeOrder();
      final String orderId = insertedOrder['id'].toString();

      // 2️⃣ Test function reachability first
      try {
        await Supabase.instance.client.functions.invoke(
          'mpesa-b2b',
          body: {'test': true},
        );
      } catch (e) {
        _toast("MPESA function unreachable. Check project URL / slug.");
        return;
      }

      // 3️⃣ Initiate MPESA STK push
      final response = await Supabase.instance.client.functions.invoke(
        'mpesa-b2b',
        body: {
          'amount': totalAmount.ceil(),
          'phone': formattedPhone,
          'orderId': orderId,
          'callbackUrl':
              'https://xnknxlkebtvbiauvazly.supabase.co/functions/v1/mpesa-b2b',
        },
      );

      final data = response.data;
      if (data == null || data['ResponseCode'] != '0') {
        _toast("Payment initiation failed!");
        return;
      }

      // 4️⃣ Show waiting dialog
      _showWaitingDialog();

      // 5️⃣ Listen to order updates
      _listenToOrder(orderId);
    } catch (e, st) {
      debugPrint('MPESA error: $e\n$st');
      _toast("Payment initiation failed!");
    } finally {
      setState(() => isPaying = false);
    }
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Waiting for MPESA confirmation..."),
          ],
        ),
      ),
    );
  }

  void _listenToOrder(String orderId) {
    final supabase = Supabase.instance.client;

    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'id',
      value: orderId,
    );

    orderChannel = supabase
        .channel('order-$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: filter,
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['payment_status'] == 'paid') {
              Navigator.pop(context);
              _toast("Payment successful 🎉");
            } else if (newRecord['payment_status'] == 'failed') {
              Navigator.pop(context);
              _toast("Payment failed. Try again.");
            }
          },
        )
        .subscribe();
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
