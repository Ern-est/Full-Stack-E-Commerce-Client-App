import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case 'pending':
        return AppTheme.goldDark;
      case 'processing':
        return const Color(0xFF6C63FF); // custom luxury purple
      case 'shipped':
        return const Color(0xFF4A90E2); // custom luxury blue
      case 'delivered':
        return const Color(0xFF3BB54A); // custom luxury green
      case 'cancelled':
        return const Color(0xFFD32F2F); // custom red
      default:
        return AppTheme.secondaryText;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
