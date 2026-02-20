class Product {
  final String id;
  final String name;
  final String? description;

  final double price; // original price
  final double finalPrice; // discounted price
  final int quantity;

  final String? appliedDiscountType;
  final double? appliedDiscountValue;

  final String? mainImage;
  final String? subcategoryId;
  final String? categoryId;

  final List<String> images;
  final bool inStock;
  final List<String> variants;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.finalPrice,
    required this.quantity,
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

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - finalPrice) / price) * 100;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final price = double.tryParse(map['price']?.toString() ?? '') ?? 0;
    final finalPrice =
        double.tryParse(map['final_price']?.toString() ?? '') ?? price;

    final quantity = map['quantity'] is int
        ? map['quantity'] as int
        : int.tryParse(map['quantity']?.toString() ?? '') ?? 0;

    final images = [
      map['main_image'],
      map['image2'],
      map['image3'],
      map['image4'],
      map['image5'],
    ].whereType<String>().where((e) => e.isNotEmpty).toList();

    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: price,
      finalPrice: finalPrice,
      quantity: quantity,
      appliedDiscountType: map['applied_discount_type']?.toString(),
      appliedDiscountValue: map['applied_discount_value'] != null
          ? double.tryParse(map['applied_discount_value'].toString())
          : null,
      mainImage: map['main_image']?.toString(),
      subcategoryId: map['subcategory_id']?.toString(),
      categoryId: map['category_id']?.toString(),
      images: images,
      inStock: quantity > 0,
      variants: const ['Default'], // can expand later
    );
  }
}
