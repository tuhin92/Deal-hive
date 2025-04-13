import 'package:application/Views/cart_screen.dart';
import 'package:application/Views/wishlist_screen.dart';
import 'package:application/Widgets/banner.dart';
import 'package:application/Widgets/category_section.dart';
import 'package:application/Widgets/products_section.dart';
import 'package:application/Widgets/marketplace_offers.dart';
import 'package:application/Widgets/chat_bot.dart' hide Product;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:application/Models/product.dart';
import 'package:application/Services/cart_service.dart';
import 'package:application/Services/wishlist_service.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  List<Product?> _products = [];
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
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WishlistScreen(),
                                ),
                              ).then((_) {
                                // Refresh the screen when returning from wishlist
                                setState(() {});
                              });
                            },
                            child: Icon(Icons.favorite_border, size: 28),
                          ),
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
                                  "${WishlistService.getWishlistCount()}",
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
                      SizedBox(width: 20),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartScreen(),
                                ),
                              ).then((_) {
                                // Refresh the screen when returning from cart
                                setState(() {});
                              });
                            },
                            child: Icon(Iconsax.shopping_bag, size: 28),
                          ),
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
                                  "${CartService.getCartCount()}",
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
                ],
              ),
            ),
            SizedBox(height: 20),

            // Banner section
            MyBanner(),

            // Categories section
            CategorySection(),

            // Products section
            ProductsSection(
              products: _products,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              sectionTitle: "For You",
            ),

            SizedBox(height: 20),

            // Marketplace Offers section
            MarketplaceOffers(),

            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) => ChatBot(
                  productPrice: 0.0,
                  productName:
                      "our products", // This indicates we're starting from home screen
                ),
          );
        },
        child: Icon(Icons.support_agent, size: 30, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
