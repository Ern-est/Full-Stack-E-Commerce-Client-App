import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
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

  void showCancelDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        title: Text(
          "Cancel Order",
          style: TextStyle(color: AppTheme.primaryText),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Enter cancellation reason",
            hintStyle: TextStyle(color: AppTheme.secondaryText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Back", style: TextStyle(color: AppTheme.primaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldDark),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await cancelOrder(controller.text.trim());
              Navigator.pop(context);
            },
            child: Text(
              "Confirm Cancel",
              style: TextStyle(color: AppTheme.pureWhite),
            ),
          ),
        ],
      ),
    );
  }

  int getCurrentStep(String status) {
    const statusOrder = ['pending', 'processing', 'shipped', 'delivered'];
    return statusOrder.indexOf(status);
  }

  Widget buildLuxuryTimeline(String status) {
    final steps = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    final currentStep = getCurrentStep(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length * 2 - 1, (index) {
        // Odd indices are lines
        if (index.isOdd) {
          final lineIndex = (index / 2).floor();
          final isActive = lineIndex < currentStep;
          return Expanded(
            child: Container(
              height: 4,
              color: isActive ? AppTheme.gold : AppTheme.divider,
            ),
          );
        }

        // Even indices are step circles
        final stepIndex = (index / 2).floor();
        final isActive = stepIndex <= currentStep && currentStep != -1;

        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.gold : AppTheme.divider,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppTheme.goldDark : AppTheme.secondaryText,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                steps[stepIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? AppTheme.primaryText
                      : AppTheme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
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
        appBar: AppBar(
          title: Text(
            'Order Details',
            style: TextStyle(color: AppTheme.primaryText),
          ),
          backgroundColor: AppTheme.ivory,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryText),
        ),
        backgroundColor: AppTheme.ivory,
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
                      Center(child: OrderStatusBadge(status: status)),
                      const SizedBox(height: 20),
                      buildLuxuryTimeline(status),
                      const SizedBox(height: 20),

                      if (status == 'cancelled' && cancelReason != null)
                        Card(
                          color: const Color(0xFFFDECEA),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cancelled by: ${cancelledBy ?? 'Unknown'}",
                                  style: TextStyle(
                                    color: const Color(0xFFD32F2F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cancelReason,
                                  style: TextStyle(color: AppTheme.primaryText),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Card(
                        color: AppTheme.pureWhite,
                        child: ListTile(
                          leading: Icon(Icons.payment, color: AppTheme.gold),
                          title: Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          subtitle: Text(
                            widget.paymentMethod,
                            style: TextStyle(color: AppTheme.secondaryText),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      Text(
                        'Order Items',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),

                      ...items.map(
                        (item) => Card(
                          color: AppTheme.pureWhite,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              item['product']?['name'] ?? 'Unknown Product',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            subtitle: Text(
                              'Qty: ${item['quantity']}',
                              style: TextStyle(color: AppTheme.secondaryText),
                            ),
                            trailing: Text(
                              'Ksh ${(item['total_price'] as num).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Ksh ${(total as num).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      if (status == 'pending')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldDark,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: showCancelDialog,
                            child: Text(
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
