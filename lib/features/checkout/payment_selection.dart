import 'dart:async';
import 'dart:convert';
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
  bool _paymentHandled = false;

  RealtimeChannel? orderChannel;
  Timer? _pollingTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    selectedPayment = ref.read(checkoutProvider).paymentMethod;
  }

  @override
  void dispose() {
    _cleanupRealtimeAndPolling();
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
      (sum, item) => sum + (item.product.finalPrice * item.quantity),
    );

    final phoneInput = await showPhoneDialog(totalAmount);
    if (phoneInput == null || phoneInput.isEmpty) return;

    final formattedPhone = formatPhoneNumber(phoneInput);

    setState(() => isPaying = true);
    _paymentHandled = false;

    try {
      /// 1️⃣ Insert order
      final insertedOrder = await checkoutNotifier.placeOrder();
      final orderId = insertedOrder['id'];

      /// 2️⃣ Call Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'mpesa-b2b',
        body: {
          'amount': totalAmount.ceil(),
          'phone': formattedPhone,
          'orderId': orderId, // guaranteed UUID string
          'callbackUrl':
              'https://xnknxlkebtvbiauvazly.supabase.co/functions/v1/mpesa-b2b/callback',
        },
      );

      final raw = response.data;
      Map<String, dynamic> data;

      if (raw is String) {
        data = jsonDecode(raw);
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      } else {
        _toast("Unexpected payment response format");
        return;
      }

      if (data['ResponseCode'] != '0') {
        _toast("Payment initiation failed!");
        return;
      }

      final checkoutRequestId = data['CheckoutRequestID'];
      if (checkoutRequestId == null) {
        _toast("Missing CheckoutRequestID");
        return;
      }

      _showWaitingDialog();

      _listenToOrder(checkoutRequestId.toString());
      _startPollingFallback(checkoutRequestId.toString());

      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 60), () {
        if (!_paymentHandled) {
          _toast("Payment still pending. Check your MPESA app.");
          _cleanupRealtimeAndPolling();
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      });
    } catch (e, st) {
      debugPrint("MPESA ERROR: $e");
      debugPrint("$st");
      _toast("MPESA unreachable");
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

  /// 🔥 REALTIME LISTENER (ignores pending)
  void _listenToOrder(String checkoutRequestId) {
    final supabase = Supabase.instance.client;

    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'mpesa_checkout_request_id',
      value: checkoutRequestId,
    );

    orderChannel = supabase
        .channel('order-$checkoutRequestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: filter,
          callback: (payload) {
            final status = payload.newRecord['payment_status']
                ?.toString()
                .toLowerCase();

            debugPrint("Realtime update: status=$status");

            if (status == 'paid' || status == 'failed') {
              _handlePaymentUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  /// 🔁 POLLING FALLBACK
  void _startPollingFallback(String checkoutRequestId) {
    final supabase = Supabase.instance.client;

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final res = await supabase
            .from('orders')
            .select()
            .eq('mpesa_checkout_request_id', checkoutRequestId)
            .maybeSingle();

        if (res == null) return;

        final status =
            res['payment_status']?.toString().toLowerCase() ?? 'pending';

        debugPrint("Polling status: $status");

        if (status == 'paid' || status == 'failed') {
          _handlePaymentUpdate(res);
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  /// 🎯 HANDLE STATUS UPDATE SAFELY
  void _handlePaymentUpdate(Map<String, dynamic> record) {
    if (_paymentHandled) return;

    final status = record['payment_status']?.toString().toLowerCase();
    final orderId = record['id'];

    if (status == null || status == 'pending') return;

    _paymentHandled = true;

    debugPrint("Final payment status for $orderId: $status");

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (status == 'paid') {
      _toast("Payment successful 🎉");
    } else if (status == 'failed') {
      _toast("Payment failed.");
    }

    _cleanupRealtimeAndPolling();
  }

  void _cleanupRealtimeAndPolling() {
    orderChannel?.unsubscribe();
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    orderChannel = null;
    _pollingTimer = null;
    _timeoutTimer = null;
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
      (sum, item) => sum + (item.product.finalPrice * item.quantity),
    );

    final bool isCartEmpty = cart.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total: Ksh ${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('MPESA'),
          leading: Radio<String>(
            value: 'MPESA',
            groupValue: selectedPayment,
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedPayment = value);
              notifier.updatePayment(value);
            },
          ),
        ),
        ListTile(
          title: const Text('Cash on Delivery'),
          leading: Radio<String>(
            value: 'COD',
            groupValue: selectedPayment,
            onChanged: (value) async {
              if (isCartEmpty) {
                _toast("Cart is empty");
                return;
              }

              setState(() => selectedPayment = value!);
              notifier.updatePayment(value!);
              await notifier.placeOrder();
              _toast("Order placed successfully!");
            },
          ),
        ),
        const SizedBox(height: 20),
        if (selectedPayment == 'MPESA')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isPaying || isCartEmpty) ? null : payWithMpesa,
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
