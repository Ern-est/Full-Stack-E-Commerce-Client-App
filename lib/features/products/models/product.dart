class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? offerPrice;
  final String? mainImage;
  final String? subcategoryId;
  final String? categoryId;
  final List<String> images; // mainImage + image2-5
  final bool inStock;
  final List<String> variants; // dynamic variants from backend

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.offerPrice,
    this.mainImage,
    this.subcategoryId,
    this.categoryId,
    required this.images,
    required this.inStock,
    required this.variants,
  });

  double get displayPrice => offerPrice ?? price;

  factory Product.fromMap(Map<String, dynamic> map, {List<String>? variants}) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: double.parse(map['price'].toString()),
      offerPrice: map['offer_price'] != null
          ? double.parse(map['offer_price'].toString())
          : null,
      mainImage: map['main_image'] as String?,
      subcategoryId: map['subcategory_id'] as String?,
      categoryId: map['category_id'] as String?,
      images: [
        map['main_image'],
        map['image2'],
        map['image3'],
        map['image4'],
        map['image5'],
      ].whereType<String>().toList(),
      inStock: (map['quantity'] as int?) != null && map['quantity'] > 0,
      variants: variants ?? ['Default'],
    );
  }
}
