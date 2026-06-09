class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String thumbnail;
  final double rating;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.rating,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price']).toDouble(),
      description: json['description'],
      thumbnail: json['thumbnail'],
      rating: (json['rating']).toDouble(),
      category: json['category'],
    );
  }
}
