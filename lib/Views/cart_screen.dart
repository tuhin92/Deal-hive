import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:application/Services/cart_service.dart';
import 'package:application/Models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    // Get cart items from service
    cartItems = CartService.getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    // Check if cart is empty
    bool isCartEmpty = cartItems.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
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
          isCartEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/empty_cart.json',
                      width: 250,
                      height: 250,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Start shopping to add items to your cart',
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
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return CartItemCard(
                          cartItem: cartItems[index],
                          onIncrease: () {
                            setState(() {
                              CartService.updateQuantity(
                                cartItems[index].product,
                                cartItems[index].quantity + 1,
                              );
                              cartItems = CartService.getCartItems();
                            });
                          },
                          onDecrease: () {
                            if (cartItems[index].quantity > 1) {
                              setState(() {
                                CartService.updateQuantity(
                                  cartItems[index].product,
                                  cartItems[index].quantity - 1,
                                );
                                cartItems = CartService.getCartItems();
                              });
                            }
                          },
                          onDelete: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Remove Item'),
                                  content: Text(
                                    'Are you sure you want to remove this item from your cart?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Remove',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          CartService.removeFromCart(
                                            cartItems[index].product,
                                          );
                                          cartItems =
                                              CartService.getCartItems();
                                        });
                                        Navigator.of(context).pop();

                                        // Show a snackbar to confirm removal
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Item removed from cart',
                                            ),
                                            duration: Duration(seconds: 1),
                                            action: SnackBarAction(
                                              label: 'UNDO',
                                              onPressed: () {
                                                setState(() {
                                                  CartService.addToCart(
                                                    cartItems[index].product,
                                                    1,
                                                  );
                                                  cartItems =
                                                      CartService.getCartItems();
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  CartSummary(totalPrice: CartService.getTotalPrice()),
                ],
              ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete; // New parameter for delete action

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete, // Add required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
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
                  cartItem.product.imageLink,
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
                    cartItem.product.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  // Add a delete button below the price
                  GestureDetector(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red[400],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: onDecrease,
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: onIncrease,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final double totalPrice;

  const CartSummary({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Checkout functionality coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Checkout'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
