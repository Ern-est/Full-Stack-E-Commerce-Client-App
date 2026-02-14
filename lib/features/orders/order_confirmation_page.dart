import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_scaffold.dart';
import 'widgets/order_status_badge.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String orderId;
  final String paymentMethod;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.paymentMethod,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final supabase = Supabase.instance.client;

  /// Matches EXACT database enum
  int getCurrentStep(String status) {
    const statusOrder = ['pending', 'processing', 'shipped', 'delivered'];

    return statusOrder.indexOf(status);
  }

  Widget buildTimeline(String status) {
    if (status == 'cancelled') {
      return const Center(
        child: Text(
          "This order was cancelled",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final steps = ['Pending', 'Processing', 'Shipped', 'Delivered'];

    final currentStep = getCurrentStep(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep && currentStep != -1;

        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive ? Colors.green : Colors.grey.shade700,
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              steps[index],
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      onNavTap: (_) {},
      body: Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: StreamBuilder(
          stream: supabase
              .from('orders')
              .stream(primaryKey: ['id'])
              .eq('id', widget.orderId),
          builder: (context, orderSnapshot) {
            if (!orderSnapshot.hasData || orderSnapshot.data!.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = orderSnapshot.data!.first;

            final status = order['order_status'] ?? 'pending';

            final total = order['total_amount'] ?? 0;

            return FutureBuilder(
              future: supabase
                  .from('order_items')
                  .select('''
      quantity,
      unit_price,
      total_price,
      product:products!order_items_product_id_fkey (
        name
      )
    ''')
                  .eq('order_id', widget.orderId),
              builder: (context, itemsSnapshot) {
                if (!itemsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = itemsSnapshot.data as List<dynamic>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// STATUS BADGE
                      Center(child: OrderStatusBadge(status: status)),
                      const SizedBox(height: 20),

                      /// TIMELINE
                      buildTimeline(status),
                      const SizedBox(height: 20),

                      /// PAYMENT METHOD
                      Card(
                        color: const Color(0xFF1E1E1E),
                        child: ListTile(
                          leading: const Icon(
                            Icons.payment,
                            color: Colors.green,
                          ),
                          title: const Text(
                            'Payment Method',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(widget.paymentMethod),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// ORDER ITEMS LIST
                      ...items.map(
                        (item) => Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              item['product']?['name'] ?? 'Unknown Product',
                            ),
                            subtitle: Text('Qty: ${item['quantity']}'),
                            trailing: Text(
                              '\$${(item['total_price'] as num).toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// TOTAL FROM ORDERS TABLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${(total as num).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
