import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rating.dart';
import '../services/ratings_service.dart';

/// Stats Provider
final productRatingStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) {
      return RatingsService.fetchStats(productId);
    });

/// Reviews Provider
final productReviewsProvider = FutureProvider.family<List<Rating>, String>((
  ref,
  productId,
) {
  return RatingsService.fetchProductReviews(productId);
});
