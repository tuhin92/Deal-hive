import 'package:application/Models/cart_item.dart';
import 'package:application/Models/product.dart';

class CartService {
  // Static list to store cart items
  static final List<CartItem> _cartItems = [];

  // Get all cart items
  static List<CartItem> getCartItems() {
    return _cartItems;
  }

  // Add item to cart
  static void addToCart(Product product, int quantity) {
    // Check if product already exists in cart
    int index = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (index != -1) {
      // Product already exists, update quantity
      _cartItems[index].quantity += quantity;
    } else {
      // Add new product to cart
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
  }

  // Remove item from cart
  static void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.name == product.name);
  }

  // Update item quantity
  static void updateQuantity(Product product, int quantity) {
    int index = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );
    if (index != -1) {
      _cartItems[index].quantity = quantity;
    }
  }

  // Calculate total price
  static double getTotalPrice() {
    return _cartItems.fold(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  // Get cart count
  static int getCartCount() {
    return _cartItems.length;
  }
}
