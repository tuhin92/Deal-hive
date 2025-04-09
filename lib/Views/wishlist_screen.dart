import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:application/Services/wishlist_service.dart';
import 'package:application/Models/wishlist_item.dart';
import 'package:application/Views/product_details.dart';
import 'package:application/Services/cart_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    // Get wishlist items from service
    wishlistItems = WishlistService.getWishlistItems();
  }

  @override
  Widget build(BuildContext context) {
    // Check if wishlist is empty
    bool isWishlistEmpty = wishlistItems.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isWishlistEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/empty_wishlist.json',
                      width: 250,
                      height: 250,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your wishlist is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Save items you love to your wishlist',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  return WishlistItemCard(
                    wishlistItem: wishlistItems[index],
                    onRemove: () {
                      setState(() {
                        WishlistService.removeFromWishlist(
                          wishlistItems[index].product,
                        );
                        wishlistItems = WishlistService.getWishlistItems();
                      });
                    },
                    onAddToCart: () {
                      CartService.addToCart(wishlistItems[index].product, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to cart'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductDetailsScreen(
                                product: wishlistItems[index].product,
                              ),
                        ),
                      ).then((_) {
                        setState(() {
                          wishlistItems = WishlistService.getWishlistItems();
                        });
                      });
                    },
                  );
                },
              ),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final WishlistItem wishlistItem;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const WishlistItemCard({
    Key? key,
    required this.wishlistItem,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    wishlistItem.product.imageLink,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (ctx, err, _) =>
                            Icon(Icons.image, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(width: 15),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlistItem.product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '\$${wishlistItem.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      wishlistItem.product.availability == "in_stock"
                          ? "In Stock"
                          : "Out of Stock",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            wishlistItem.product.availability == "in_stock"
                                ? Colors.green[600]
                                : Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: onRemove,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 5),
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    onPressed:
                        wishlistItem.product.availability == "in_stock"
                            ? onAddToCart
                            : null,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
