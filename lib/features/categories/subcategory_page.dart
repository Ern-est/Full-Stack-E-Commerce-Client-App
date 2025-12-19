import 'package:flutter/material.dart';
import '../../core/app_scaffold.dart';
import '../../core/responsive.dart';
import 'product_list_page.dart';

class SubcategoryPage extends StatelessWidget {
  final String categoryName;

  const SubcategoryPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    int columns = 2;
    if (Responsive.isTablet(context)) columns = 3;
    if (Responsive.isDesktop(context)) columns = 5;

    return AppScaffold(
      currentIndex: 0,
      onNavTap: (_) {},
      body: Scaffold(
        appBar: AppBar(title: Text(categoryName)),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, i) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductListPage(subcategoryName: 'Subcategory ${i + 1}'),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Subcategory ${i + 1}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
