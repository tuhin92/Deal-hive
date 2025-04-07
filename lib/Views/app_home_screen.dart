import 'package:application/Widgets/banner.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:application/Views/product_details.dart'; // Add this import

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
      price: double.tryParse(json['price'] ?? '0') ?? 0.0,
      imageLink: json['imageLink'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print("Fetching products from API...");
      final response = await http.get(
        Uri.parse('https://deal-hive-server.vercel.app/products'),
      );

      print("API Response Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print("Response body length: ${responseBody.length}");

        final List<dynamic> productsJson = json.decode(responseBody);
        print("Parsed ${productsJson.length} products");

        setState(() {
          _products =
              productsJson.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
          print("Products loaded: ${_products.length}");
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load products. Status code: ${response.statusCode}';
          _isLoading = false;
          print("Error: $_errorMessage");
        });
      }
    } catch (e) {
      print("Exception occurred: ${e.toString()}");
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoryItem(String imageUrl, String categoryName) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 40);
            },
          ),
          SizedBox(height: 8),
          Text(
            categoryName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemFromAPI(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Changed from Colors.grey[50] to white
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ), // Keeping the subtle shadow
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist icon
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: const Color.fromARGB(
                  255,
                  255,
                  254,
                  254,
                ), // Very light gray background for the image
                child: Stack(
                  children: [
                    // Background gradient for visual appeal
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.withOpacity(0.1),
                            Colors.grey.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                    // Product image
                    Center(
                      child: Image.network(
                        product.imageLink,
                        fit: BoxFit.contain,
                        height:
                            110, // Slightly smaller than container for padding effect
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error, size: 40));
                        },
                      ),
                    ),
                    // Wishlist icon on top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Add wishlist functionality here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added to wishlist'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Brand
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ), // Changed from grey[600] to grey[400]
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Price
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  // Availability
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          product.availability == "in_stock"
                              ? Colors.green[50] // Lighter green background
                              : Colors.red[50], // Lighter red background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.availability == "in_stock"
                          ? "In Stock"
                          : "Out of Stock",
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            product.availability == "in_stock"
                                ? Colors.green[600] // Lighter green text
                                : Colors.red[600], // Lighter red text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem({
    required String imageUrl,
    required String name,
    required double price,
    required double discountPrice,
    required double rating,
  }) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Price and discount
                Row(
                  children: [
                    Text(
                      "\$${discountPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Rating
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return Container(
        height: 230, // Increased height from 220 to 230
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        height: 230, // Increased height
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
        height: 230, // Increased height
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: Text('No products available')),
      );
    }

    return Container(
      height: 230, // Increased height from 220 to 230
      padding: EdgeInsets.only(left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return _buildProductItemFromAPI(_products[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            // header part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/logo.png", height: 40),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Iconsax.shopping_bag, size: 28),
                      Positioned(
                        right: -3,
                        top: -5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "2",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // for banner part
            MyBanner(),

            // shop by category part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shop by Category",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                ],
              ),
            ),

            // category items part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3194/3194766.png",
                      "Fruits",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3075/3075975.png",
                      "Fish",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3004/3004458.png",
                      "Medicine",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/1005/1005665.png",
                      "Beauty",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3659/3659899.png",
                      "Electronics",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/2331/2331966.png",
                      "Clothing",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/1830/1830847.png",
                      "Home & Kitchen",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/857/857418.png",
                      "Sports & Outdoors",
                    ),
                  ],
                ),
              ),
            ),

            // For You section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "For You",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                ],
              ),
            ),

            // For You products - API-driven section
            _buildProductsList(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
