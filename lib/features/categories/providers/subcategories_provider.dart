import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subcategory.dart';

final subCategoriesProvider = FutureProvider.family<List<SubCategory>, String>((
  ref,
  categoryId,
) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('subcategories')
      .select()
      .eq('category_id', categoryId)
      .order('created_at');

  return (data as List)
      .map((e) => SubCategory.fromMap(e as Map<String, dynamic>))
      .toList();
});
