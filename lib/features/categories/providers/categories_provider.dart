import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final supabase = Supabase.instance.client;

  final data = await supabase.from('categories').select().order('created_at');

  return (data as List)
      .map((e) => Category.fromMap(e as Map<String, dynamic>))
      .toList();
});
