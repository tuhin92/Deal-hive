import 'package:application/Widgets/chat_bot.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application/Views/product_details.dart';
import 'package:application/Models/product.dart'; // Add this import

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://deal-hive-server.vercel.app/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        final products =
            productsJson.map((json) => Product.fromJson(json)).toList();

        // Extract unique categories
        final Set<String> categoriesSet =
            products.map((p) => p.category).toSet();

        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _categories = categoriesSet.toList()..sort();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts =
          _allProducts.where((product) {
            // Filter by search query
            final nameMatches = product.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final brandMatches = product.brand.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final descriptionMatches = product.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

            // Filter by category if selected
            final categoryMatches =
                _selectedCategory == null ||
                product.category == _selectedCategory;

            return (nameMatches || brandMatches || descriptionMatches) &&
                categoryMatches;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for deals...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterProducts();
              },
            ),
            const SizedBox(height: 16),

            // Category filter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Filter by Category'),
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category.capitalize()),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _filterProducts();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            _isLoading
                ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
                : _hasError
                ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Failed to load products',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
                : _filteredProducts.isEmpty
                ? const Expanded(
                  child: Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
                : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
                ),
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
                  productPrice:
                      _filteredProducts.isNotEmpty
                          ? _filteredProducts[0].price
                          : 0.0,
                  productName:
                      _filteredProducts.isNotEmpty
                          ? _filteredProducts[0].name
                          : "our products",
                ),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailsScreen(
                  product: product, // Pass the product directly
                ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade50,
                ),
                child: Image.network(
                  product.imageLink,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (ctx, error, _) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                  loadingBuilder: (ctx, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with limited height
                    SizedBox(
                      height: 36, // Fixed height for name
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Brand with limited height
                    SizedBox(
                      height: 16, // Fixed height for brand
                      child: Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price and availability with spacer to push to bottom
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}', // Format the double price
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                product.availability == 'in_stock'
                                    ? Colors.green.shade100
                                    : product.availability == 'pre_order'
                                    ? Colors.amber.shade100
                                    : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.availability
                                .replaceAll('_', ' ')
                                .capitalize(),
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  product.availability == 'in_stock'
                                      ? Colors.green.shade800
                                      : product.availability == 'pre_order'
                                      ? Colors.amber.shade800
                                      : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');
  }
}
