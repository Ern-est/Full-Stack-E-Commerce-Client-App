import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

final productsProvider = FutureProvider.family<List<Product>, String?>((
  ref,
  subCategoryId,
) async {
  final supabase = Supabase.instance.client;

  // Build the query
  var query = supabase.from('products').select();

  if (subCategoryId != null) {
    query = query.eq('subcategory_id', subCategoryId);
  }

  // Execute the query
  final res = await query;

  // 'res' is already List<dynamic> in the new version
  final data = res as List<dynamic>;

  return data.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
});
