import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

final productDetailsProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final supabase = Supabase.instance.client;

  // Fetch product
  final productMap = await supabase
      .from('products_with_discount')
      .select()
      .eq('id', productId)
      .single();

  // Fetch variants
  List<String> variants = ['Default'];

  if (productMap['variant_type_id'] != null) {
    final variantRes = await supabase
        .from('variants')
        .select('name')
        .eq('variant_type_id', productMap['variant_type_id']);

    final variantList = variantRes as List;

    variants = variantList
        .map((v) => (v as Map<String, dynamic>)['name'] as String)
        .toList();

    if (variants.isEmpty) variants = ['Default'];
  }

  // Create base product
  final baseProduct = Product.fromMap(productMap);

  // Return new product with variants
  return Product(
    id: baseProduct.id,
    name: baseProduct.name,
    description: baseProduct.description,
    price: baseProduct.price,
    finalPrice: baseProduct.finalPrice,
    quantity: baseProduct.quantity,
    appliedDiscountType: baseProduct.appliedDiscountType,
    appliedDiscountValue: baseProduct.appliedDiscountValue,
    mainImage: baseProduct.mainImage,
    subcategoryId: baseProduct.subcategoryId,
    categoryId: baseProduct.categoryId,
    images: baseProduct.images,
    inStock: baseProduct.inStock,
    variants: variants,
  );
});
