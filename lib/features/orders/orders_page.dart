import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/features/orders/order_confirmation_page.dart';
import 'package:full_stack_e_commerce_app/features/orders/widgets/order_status_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder(
        stream: supabase
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('client_id', userId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data as List<dynamic>;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final status = order['order_status'] ?? 'pending';
              final paymentMethod = order['payment_method'] ?? 'COD';
              final total = order['total_amount'] ?? 0.0;

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderConfirmationPage(
                          orderId: order['id'],
                          paymentMethod: paymentMethod,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    "Order #${order['id'].toString().substring(0, 8)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      OrderStatusBadge(status: status),
                      const SizedBox(height: 6),
                      Text(
                        "Payment: $paymentMethod",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Text(
                    "\$${(total as num).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
