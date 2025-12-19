import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/products/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productDetailsProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final supabase = Supabase.instance.client;

  // 1️⃣ Fetch product
  final productMap = await supabase
      .from('products')
      .select()
      .eq('id', productId)
      .single();

  // 2️⃣ Fetch variants for this product (if variant_type_id exists)
  List<String> variants = ['Default'];
  if (productMap['variant_type_id'] != null) {
    final variantRes = await supabase
        .from('variants')
        .select('name')
        .eq('variant_type_id', productMap['variant_type_id']);

    variants = (variantRes as List)
        .map((v) => (v as Map<String, dynamic>)['name'] as String)
        .toList();

    if (variants.isEmpty) variants = ['Default'];
  }

  return Product.fromMap(productMap, variants: variants);
});
