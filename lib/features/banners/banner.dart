class BannerModel {
  final int id;
  final String? title;
  final String imageUrl;
  final String? link;
  final bool status;

  BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    this.link,
    required this.status,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] as int,
      title: map['title'] as String?,
      imageUrl: map['image_url'] as String,
      link: map['link'] as String?,
      status: map['status'] as bool? ?? true,
    );
  }
}
