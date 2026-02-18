import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/ratings/providers/ratings_provider.dart';
import '../services/ratings_service.dart';

class WriteReviewSheet extends ConsumerStatefulWidget {
  final String productId;

  const WriteReviewSheet({super.key, required this.productId});

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  int rating = 5;
  bool isSubmitting = false;
  final commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Write Review", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: () => setState(() => rating = i + 1),
                icon: Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              ),
            ),
          ),

          TextField(
            controller: commentCtrl,
            decoration: const InputDecoration(labelText: "Comment"),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    setState(() => isSubmitting = true);

                    await RatingsService.addReview(
                      productId: widget.productId,
                      rating: rating,
                      comment: commentCtrl.text,
                    );

                    ref.invalidate(productReviewsProvider(widget.productId));
                    ref.invalidate(
                      productRatingStatsProvider(widget.productId),
                    );

                    if (mounted) Navigator.pop(context);
                  },
            child: isSubmitting
                ? const CircularProgressIndicator()
                : const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
