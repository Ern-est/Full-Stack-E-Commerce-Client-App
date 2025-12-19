class SubCategory {
  final String id;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final DateTime createdAt;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.createdAt,
    this.imageUrl,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['image_url'],
      categoryId: map['category_id'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
