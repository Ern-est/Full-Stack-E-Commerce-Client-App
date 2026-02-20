import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/products_params.dart';

final productsProvider = FutureProvider.family<List<Product>, ProductsParams>((
  ref,
  params,
) async {
  final supabase = Supabase.instance.client;

  var query = supabase.from('products_with_discount').select();

  // Filter by subcategory
  if (params.subId != null) {
    query = query.eq('subcategory_id', params.subId!);
  }

  // Filter by search
  if (params.search.isNotEmpty) {
    query = query.ilike('name', '%${params.search}%');
  }

  final response = await query;

  final data = response as List<dynamic>;

  return data.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
});
