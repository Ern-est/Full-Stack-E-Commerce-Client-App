import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/banners/banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('banners')
      .select()
      .eq('status', true)
      .order('created_at', ascending: false);

  return (data as List)
      .map((e) => BannerModel.fromMap(e as Map<String, dynamic>))
      .toList();
});
