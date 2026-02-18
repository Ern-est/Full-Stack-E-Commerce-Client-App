class Rating {
  final String id;
  final String productId;
  final String clientId;
  final int rating;
  final String? comment;
  final bool verified;
  final DateTime createdAt;
  final String? clientName;

  Rating({
    required this.id,
    required this.productId,
    required this.clientId,
    required this.rating,
    this.comment,
    required this.verified,
    required this.createdAt,
    this.clientName,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      productId: map['product_id'],
      clientId: map['client_id'],
      rating: map['rating'],
      comment: map['comment'],
      verified: map['verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      clientName: map['clients']?['name'],
    );
  }
}
