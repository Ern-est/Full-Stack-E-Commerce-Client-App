import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import '../models/subcategory.dart';

class SubCategoryCard extends StatelessWidget {
  final SubCategory subCategory;
  final VoidCallback onTap;

  const SubCategoryCard({
    super.key,
    required this.subCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppTheme.gold.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        alignment: Alignment.center,
        child: Text(
          subCategory.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
      ),
    );
  }
}
