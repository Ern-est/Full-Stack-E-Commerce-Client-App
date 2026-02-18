import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/products/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productsProvider = FutureProvider.family<List<Product>, String?>((
  ref,
  subCategoryId,
) async {
  final supabase = Supabase.instance.client;

  var query = supabase.from('products_with_discount').select();

  if (subCategoryId != null) {
    query = query.eq('subcategory_id', subCategoryId);
  }

  final res = await query;
  final data = res as List<dynamic>;

  return data.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
});
