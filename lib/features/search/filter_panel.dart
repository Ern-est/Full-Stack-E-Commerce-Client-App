import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final String selectedCategory;
  final double maxPrice;
  final int minRating;
  final void Function(String, double, int) onFilterChange;

  const FilterPanel({
    super.key,
    required this.selectedCategory,
    required this.maxPrice,
    required this.minRating,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Electronics', 'Clothing', 'Shoes', 'Home'];

    return Column(
      children: [
        // Category Dropdown
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (val) {
            if (val != null) onFilterChange(val, maxPrice, minRating);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Price Slider
        Row(
          children: [
            const Text('Max Price'),
            Expanded(
              child: Slider(
                value: maxPrice,
                min: 0,
                max: 1000,
                divisions: 20,
                label: maxPrice.toStringAsFixed(0),
                onChanged: (val) =>
                    onFilterChange(selectedCategory, val, minRating),
              ),
            ),
          ],
        ),

        // Rating Filter
        Row(
          children: [
            const Text('Min Rating'),
            Expanded(
              child: Slider(
                value: minRating.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: minRating.toString(),
                onChanged: (val) =>
                    onFilterChange(selectedCategory, maxPrice, val.toInt()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
