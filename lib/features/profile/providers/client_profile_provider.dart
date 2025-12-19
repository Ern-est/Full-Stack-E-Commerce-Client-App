import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

final clientProfileProvider = FutureProvider<Client>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('No user logged in');

  final clientMap = await supabase
      .from('clients')
      .select()
      .eq('id', userId)
      .single();

  return Client.fromMap(clientMap);
});
