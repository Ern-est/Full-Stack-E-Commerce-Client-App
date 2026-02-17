import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:full_stack_e_commerce_app/features/cart/cart_provider.dart';

/// PROVIDER
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(ref),
);

/// STATE
class CheckoutState {
  final int step;
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;

  CheckoutState({
    this.step = 0,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.paymentMethod = 'MPESA',
  });

  CheckoutState copyWith({
    int? step,
    String? name,
    String? phone,
    String? address,
    String? paymentMethod,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// NOTIFIER
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;
  CheckoutNotifier(this.ref) : super(CheckoutState());

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  void saveShipping() {
    state = state.copyWith(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
    );
  }

  void updatePayment(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void nextStep() {
    saveShipping();
    state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void reset() {
    nameCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    state = CheckoutState();
  }

  /// ✅ PLACE ORDER (FULL DEBUG + SAFE)
  Future<Map<String, dynamic>> placeOrder() async {
    final cart = ref.read(cartProvider);

    if (cart.isEmpty) {
      throw Exception('Cart is empty');
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final String clientId = user.id;

    try {
      /// 1️⃣ Ensure client exists
      final existingClient = await supabase
          .from('clients')
          .select('id')
          .eq('id', clientId)
          .maybeSingle();

      if (existingClient == null) {
        debugPrint('Client does not exist. Creating new client...');
        final clientInsert = await supabase
            .from('clients')
            .insert({
              'id': clientId,
              'name': state.name.isEmpty ? 'No Name' : state.name,
              'phone': state.phone,
              'email': user.email,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .maybeSingle();

        debugPrint('Inserted client: $clientInsert');
      }

      /// 2️⃣ Insert order
      final insertedOrder = await supabase
          .from('orders')
          .insert({
            'client_id': clientId,
            'total_amount': cart.fold<double>(
              0,
              (sum, item) => sum + (item.product.displayPrice * item.quantity),
            ),
            'payment_method': state.paymentMethod,
            'payment_status': 'pending',
            'delivery_address': state.address,
            'notes': 'Order placed via app',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      debugPrint('Inserted order: $insertedOrder');

      final orderIdRaw = insertedOrder['id'];
      if (orderIdRaw == null || orderIdRaw.toString().isEmpty) {
        throw Exception('Inserted order has no ID! Cannot proceed.');
      }
      final String orderId = orderIdRaw.toString();
      debugPrint('Order ID: $orderId');

      /// 3️⃣ Insert order items
      final orderItems = cart.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.product.displayPrice,
          'total_price': item.product.displayPrice * item.quantity,
          'variant': item.selectedVariant,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await supabase.from('order_items').insert(orderItems);
      debugPrint('Inserted ${orderItems.length} order items');

      /// 4️⃣ Fetch full order with items
      final orderWithItems = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .maybeSingle();

      debugPrint('Full order fetched: $orderWithItems');

      /// 5️⃣ Clear cart AFTER everything succeeds
      ref.read(cartProvider.notifier).clearCart();
      debugPrint('Cart cleared');

      return orderWithItems ?? insertedOrder;
    } catch (e, st) {
      debugPrint('ERROR in placeOrder(): $e');
      debugPrint('$st');
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }
}
