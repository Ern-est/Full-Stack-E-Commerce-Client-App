import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';

class SideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SideNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppTheme.pureWhite,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.shopping_cart_outlined, 'Cart', 1),
          _navItem(Icons.receipt_long_outlined, 'Orders', 2),
          _navItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = index == currentIndex;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.goldTint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.gold : AppTheme.secondaryText,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppTheme.gold : AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
