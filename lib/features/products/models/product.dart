class Product {
  final String id;
  final String name;
  final String? description;
  final double price; // original price
  final double finalPrice; // discounted price (from view)
  final String? appliedDiscountType;
  final double? appliedDiscountValue;
  final String? mainImage;
  final String? subcategoryId;
  final String? categoryId;
  final List<String> images;
  final bool inStock;
  final List<String> variants;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.finalPrice,
    this.appliedDiscountType,
    this.appliedDiscountValue,
    this.mainImage,
    this.subcategoryId,
    this.categoryId,
    required this.images,
    required this.inStock,
    required this.variants,
  });

  bool get hasDiscount => finalPrice < price;

  factory Product.fromMap(Map<String, dynamic> map, {List<String>? variants}) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: double.parse(map['price'].toString()),
      finalPrice: map['final_price'] != null
          ? double.parse(map['final_price'].toString())
          : double.parse(map['price'].toString()),
      appliedDiscountType: map['applied_discount_type'] as String?,
      appliedDiscountValue: map['applied_discount_value'] != null
          ? double.parse(map['applied_discount_value'].toString())
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
