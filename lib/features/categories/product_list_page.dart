import 'package:flutter/material.dart';
import '../../core/app_scaffold.dart';
import '../../core/responsive.dart';

class ProductListPage extends StatelessWidget {
  final String subcategoryName;

  const ProductListPage({super.key, required this.subcategoryName});

  @override
  Widget build(BuildContext context) {
    int columns = 2;
    if (Responsive.isTablet(context)) columns = 3;
    if (Responsive.isDesktop(context)) columns = 5;

    return AppScaffold(
      currentIndex: 0,
      onNavTap: (_) {},
      body: Scaffold(
        appBar: AppBar(title: Text(subcategoryName)),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text('Product Name'),
                      SizedBox(height: 4),
                      Text(
                        'Ksh 99.99', // Updated currency symbol
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
