class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
    );
  }
    Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
    );
  }
}