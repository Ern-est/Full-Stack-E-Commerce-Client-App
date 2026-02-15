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

  /// ==============================
  /// CANCEL ORDER FUNCTION
  /// ==============================
  Future<void> cancelOrder(String reason) async {
    await supabase
        .from('orders')
        .update({
          'order_status': 'cancelled',
          'cancelled_by': 'client',
          'cancel_reason': reason,
          'cancelled_at': DateTime.now().toIso8601String(),
        })
        .eq('id', widget.orderId);
  }

  /// ==============================
  /// CANCEL DIALOG
  /// ==============================
  void showCancelDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Cancel Order"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter cancellation reason",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await cancelOrder(controller.text.trim());

              Navigator.pop(context);
            },
            child: const Text("Confirm Cancel"),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// STEP TRACKER
  /// ==============================
  int getCurrentStep(String status) {
    const statusOrder = ['pending', 'processing', 'shipped', 'delivered'];
    return statusOrder.indexOf(status);
  }

  Widget buildTimeline(String status) {
    if (status == 'cancelled') {
      return Column(
        children: const [
          Icon(Icons.cancel, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "This order was cancelled",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
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

  /// ==============================
  /// UI BUILD
  /// ==============================
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

            final cancelledBy = order['cancelled_by'];
            final cancelReason = order['cancel_reason'];

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

                      /// CANCELLATION REASON
                      if (status == 'cancelled' && cancelReason != null)
                        Card(
                          color: const Color(0xFF2A0000),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cancelled by: ${cancelledBy ?? 'Unknown'}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cancelReason,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

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

                      /// ORDER ITEMS
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

                      /// TOTAL
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

                      const SizedBox(height: 30),

                      /// CANCEL BUTTON (ONLY IF PENDING)
                      if (status == 'pending')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: showCancelDialog,
                            child: const Text(
                              "Cancel Order",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
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
