import 'package:flutter/material.dart';
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          subCategory.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
