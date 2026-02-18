class Rating {
  final String id;
  final String productId;
  final String clientId;
  final String? orderId;
  final int rating;
  final String? comment;
  final bool verified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? clientName;

  Rating({
    required this.id,
    required this.productId,
    required this.clientId,
    this.orderId,
    required this.rating,
    this.comment,
    required this.verified,
    required this.createdAt,
    this.updatedAt,
    this.clientName,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      productId: map['product_id'],
      clientId: map['client_id'],
      orderId: map['order_id'],
      rating: map['rating'],
      comment: map['comment'],
      verified: map['verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      clientName: map['clients']?['name'],
    );
  }
}
