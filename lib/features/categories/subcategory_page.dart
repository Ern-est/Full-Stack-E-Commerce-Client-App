import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
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
        appBar: AppBar(
          title: Text(
            categoryName,
            style: AppTheme.luxuryTheme.textTheme.titleLarge,
          ),
          backgroundColor: AppTheme.ivory,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.primaryText),
        ),
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
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppTheme.goldTint, width: 1),
              ),
              child: Center(
                child: Text(
                  'Subcategory ${i + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
