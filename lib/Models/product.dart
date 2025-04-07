class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String availability;
  final double price;
  final String imageLink;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.availability,
    required this.price,
    required this.imageLink,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      availability: json['availability'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageLink: json['imageLink'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
