import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

final relatedProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  subcategoryId,
) async {
  if (subcategoryId.isEmpty) return [];

  final supabase = Supabase.instance.client;

  final res = await supabase
      .from('products')
      .select()
      .eq('subcategory_id', subcategoryId)
      .limit(10); // Limit to 10 related products

  return (res as List<dynamic>)
      .map((e) => Product.fromMap(e as Map<String, dynamic>))
      .toList();
});
