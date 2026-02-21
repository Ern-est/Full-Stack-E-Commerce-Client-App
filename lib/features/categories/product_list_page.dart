import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../../../core/responsive.dart';
import '../../core/app_scaffold.dart';

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
        backgroundColor: AppTheme.ivory,
        appBar: AppBar(
          title: Text(subcategoryName),
          backgroundColor: AppTheme.ivory,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 12, // placeholder
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.divider.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Product Name',
                        style: TextStyle(color: AppTheme.primaryText),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ksh 99.99',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                        ),
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
