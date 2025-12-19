import 'package:flutter/material.dart';
import '../../core/app_scaffold.dart';
import 'order_confirmation_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = List.generate(
      6,
      (i) => {
        'orderId': 'ORD2025${i + 1}',
        'date': DateTime.now().subtract(Duration(days: i * 2)),
        'total': 99.99 * (i + 1),
        'status': i % 2 == 0 ? 'Delivered' : 'Pending',
      },
    );

    return AppScaffold(
      currentIndex: 0,
      onNavTap: (_) {},
      body: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: orders.isEmpty
            ? const Center(child: Text('No orders yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        'Order ID: ${order['orderId']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Date: ${order['date'].toLocal().toString().split(' ')[0]}\nStatus: ${order['status']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        '\$${order['total'].toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // Open order details (reuse confirmation page)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderConfirmationPage(
                              orderId: order['orderId'],
                              paymentMethod: 'MPESA',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
