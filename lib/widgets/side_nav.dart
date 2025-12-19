import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SideNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _navItem(Icons.home, 'Home', 0),
          _navItem(Icons.shopping_cart, 'Cart', 1),
          _navItem(Icons.receipt, 'Orders', 2),
          _navItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = index == currentIndex;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.white),
      title: Text(
        label,
        style: TextStyle(color: selected ? Colors.blue : Colors.white),
      ),
      onTap: () => onTap(index),
    );
  }
}
