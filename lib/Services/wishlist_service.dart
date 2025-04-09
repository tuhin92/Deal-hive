import 'package:application/Models/wishlist_item.dart';
import 'package:application/Models/product.dart';

class WishlistService {
  // Static list to store wishlist items
  static final List<WishlistItem> _wishlistItems = [];

  // Get all wishlist items
  static List<WishlistItem> getWishlistItems() {
    return _wishlistItems;
  }

  // Add item to wishlist
  static void addToWishlist(Product product) {
    // Check if product already exists in wishlist
    bool exists = _wishlistItems.any(
      (item) => item.product.name == product.name,
    );

    if (!exists) {
      // Add new product to wishlist
      _wishlistItems.add(
        WishlistItem(product: product, dateAdded: DateTime.now()),
      );
    }
  }

  // Remove item from wishlist
  static void removeFromWishlist(Product product) {
    _wishlistItems.removeWhere((item) => item.product.name == product.name);
  }

  // Check if product is in wishlist
  static bool isInWishlist(Product product) {
    return _wishlistItems.any((item) => item.product.name == product.name);
  }

  // Get wishlist count
  static int getWishlistCount() {
    return _wishlistItems.length;
  }
}
