import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:full_stack_e_commerce_app/features/orders/order_confirmation_page.dart';
import 'widgets/order_status_badge.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: AppTheme.ivory,
        elevation: 0,
      ),
      backgroundColor: AppTheme.ivory,
      body: StreamBuilder(
        stream: supabase
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('client_id', userId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          final orders = snapshot.data as List<dynamic>;
          if (orders.isEmpty) {
            return Center(
              child: Text(
                "No orders yet.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['order_status'] ?? 'pending';
              final paymentMethod = order['payment_method'] ?? 'COD';
              final total = order['total_amount'] ?? 0.0;

              return Card(
                color: AppTheme.pureWhite,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.goldTint, width: 1),
                ),
                shadowColor: AppTheme.goldDark.withOpacity(0.2),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppTheme.primaryText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      OrderStatusBadge(status: status),
                      const SizedBox(height: 6),
                      Text(
                        "Payment: $paymentMethod",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  trailing: Text(
                    "Ksh ${(total as num).toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppTheme.goldDark,
                      fontWeight: FontWeight.w700,
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
