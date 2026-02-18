import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating.dart';

class RatingsService {
  static final _supabase = Supabase.instance.client;

  /// Fetch product reviews
  static Future<List<Rating>> fetchProductReviews(String productId) async {
    final res = await _supabase
        .from('ratings')
        .select('*, clients(name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (res as List).map((e) => Rating.fromMap(e)).toList();
  }

  /// Fetch stats
  static Future<Map<String, dynamic>> fetchStats(String productId) async {
    final res = await _supabase.rpc(
      'get_product_rating_stats',
      params: {'p_product_id': productId},
    );

    return res ?? {};
  }

  /// Add review
  static Future<void> addReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    await _supabase.from('ratings').insert({
      'product_id': productId,
      'client_id': user.id,
      'rating': rating,
      'comment': comment,
      'verified': true, // later we can auto-check purchase
    });
  }

  /// Update review
  static Future<void> updateReview({
    required String ratingId,
    required int rating,
    String? comment,
  }) async {
    await _supabase
        .from('ratings')
        .update({
          'rating': rating,
          'comment': comment,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ratingId);
  }

  static Future<void> deleteReview(String ratingId) async {
    await _supabase.from('ratings').delete().eq('id', ratingId);
  }
}
