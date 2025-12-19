import 'package:flutter/material.dart';

class OrderHistoryItem extends StatelessWidget {
  final String orderId;
  final DateTime date;
  final double total;
  final String status;
  final VoidCallback onTap;

  const OrderHistoryItem({
    super.key,
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          'Order ID: $orderId',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Date: ${date.toLocal().toString().split(' ')[0]}\nStatus: $status',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
