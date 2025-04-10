import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:application/Models/product.dart';

class ChatBot extends StatefulWidget {
  final double productPrice;
  final String productName;

  const ChatBot({
    Key? key,
    required this.productPrice,
    required this.productName,
  }) : super(key: key);

  @override
  State<ChatBot> createState() => _ChatBotState();
}

// Update the ChatBot class to handle product selection

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isBotTyping = false;
  String? _selectedProduct;
  List<Product> _allProducts = [];
  bool _isLoadingProducts = false;
  double? _currentPrice;

  // Add these new properties
  bool _isFirstOffer = true;
  double? _lastOfferedPrice;
  bool _waitingForConfirmation = false;
  bool _isNegotiationComplete = false;
  bool _hasReachedFinalOffer = false;

  // Add these properties to the _ChatBotState class
  bool _isShowingCategoryProducts = false;
  bool _isExitingChat = false;

  // Add this property to control typing animation duration
  int _typingDelay = 800; // milliseconds

  @override
  void initState() {
    super.initState();
    if (widget.productName == "our products") {
      _fetchProducts(); // Fetch products when starting from home screen
      _addBotMessage(
        "Hello! I'm DealBot. You can tell me which product you're interested in buying, "
        "or ask me to show products in a specific category like 'medicine', 'beauty', etc.",
      );
    } else {
      _selectedProduct = widget.productName;
      _currentPrice = widget.productPrice;
      _addBotMessage(
        "Hello! I'm DealBot. I see you're interested in ${widget.productName}. "
        "The current price is \$${widget.productPrice.toStringAsFixed(2)}. "
        "What price would you like to negotiate for?",
      );
    }
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoadingProducts = true;
      });

      final response = await http.get(
        Uri.parse('https://deal-hive-server.vercel.app/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        setState(() {
          _allProducts =
              productsJson.map((json) => Product.fromJson(json)).toList();
          _isLoadingProducts = false;
        });
      } else {
        setState(() {
          _isLoadingProducts = false;
          _addBotMessage(
            "Sorry, I'm having trouble accessing the product database. Please try again later.",
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
        _addBotMessage("Sorry, something went wrong. Please try again later.");
      });
    }
  }

  // Add this method to dynamically set typing delay based on message length
  int _calculateTypingDelay(String message) {
    // Base delay plus additional time per character
    return 800 + (message.length * 20);
  }

  void _addBotMessage(String message) {
    setState(() {
      _isBotTyping = true;
    });

    // Calculate realistic typing delay based on message length
    _typingDelay = _calculateTypingDelay(message);

    // Simulate realistic typing time
    Future.delayed(Duration(milliseconds: _typingDelay), () {
      setState(() {
        _messages.add(ChatMessage(message: message, isBot: true));
        _isBotTyping = false;
      });
    });
  }

  // Improve product description formatting to handle markdown-like content
  String _formatProductDescription(String description) {
    // Handle basic markdown-style formatting
    String formatted = description
        .replaceAll('**', '') // Remove bold indicators
        .replaceAll('__', ''); // Remove underline indicators
    return formatted;
  }

  // Enhanced product display method
  void _displayProductDetails(Product product) {
    String formattedDescription = _formatProductDescription(
      product.description,
    );
    String categoryName =
        product.category.substring(0, 1).toUpperCase() +
        product.category.substring(1);

    _addBotMessage(
      "Here's information about ${product.name}:\n\n"
      "• Price: \$${product.price.toStringAsFixed(2)}\n"
      "• Category: $categoryName\n"
      "• Brand: ${product.brand}\n"
      "• Availability: ${product.availability == 'in_stock' ? 'In Stock' : 'Out of Stock'}\n\n"
      "$formattedDescription\n\n"
      "Would you like to negotiate the price for this item?",
    );
  }

  // Replace _handleUserMessage with enhanced version
  void _handleUserMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(message: message, isBot: false));
      _messageController.clear();
      _isBotTyping = true;
    });

    // Add realistic delay before processing to simulate thinking
    Future.delayed(Duration(milliseconds: 500), () {
      if (_selectedProduct == null) {
        _processProductSelection(message);
      } else {
        _processBotResponse(message);
      }
    });
  }

  void _processProductSelection(String userMessage) {
    if (_isLoadingProducts) {
      _addBotMessage(
        "I'm still loading the product list. Please wait a moment...",
      );
      return;
    }

    setState(() {
      _isBotTyping = false;

      // Search for products
      String searchQuery = userMessage.toLowerCase();
      List<Product> matchingProducts =
          _allProducts.where((product) {
            return product.name.toLowerCase().contains(searchQuery) ||
                product.brand.toLowerCase().contains(searchQuery) ||
                product.category.toLowerCase().contains(searchQuery);
          }).toList();

      if (matchingProducts.isEmpty) {
        _addBotMessage(
          "I couldn't find any products matching '$userMessage'. "
          "Please try another product name or check our available products.",
        );
      } else if (matchingProducts.length > 1) {
        // Multiple products found
        String productList = matchingProducts
            .take(3) // Show only first 3 matches to avoid long messages
            .map((p) => "\n- ${p.name} (\$${p.price.toStringAsFixed(2)})")
            .join("");

        _addBotMessage(
          "I found several products matching your search:$productList\n\n"
          "Please specify which one you're interested in.",
        );
      } else {
        // Single product found
        Product product = matchingProducts[0];
        _selectedProduct = product.name;
        _currentPrice = product.price;
        _addBotMessage(
          "I found ${product.name}! "
          "The current price is \$${product.price.toStringAsFixed(2)}. "
          "What price would you like to negotiate for?",
        );
      }
    });
  }

  // Update the _processBotResponse method to better handle rejection and categories

  void _processBotResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase().trim();

    // Handle direct chat closing request
    if (lowerMessage.contains("close chat") ||
        lowerMessage.contains("bye") ||
        lowerMessage.contains("goodbye") ||
        (lowerMessage.contains("don't") && lowerMessage.contains("want")) ||
        (lowerMessage.contains("do not") && lowerMessage.contains("want")) ||
        (lowerMessage.contains("not") && lowerMessage.contains("now"))) {
      _addBotMessage(
        "Thank you for chatting with me today! Have a great day. Closing chat now...",
      );
      // Wait 2 seconds then close the chat
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
      return;
    }

    // Handle exit chat flow
    if (_isExitingChat) {
      if (lowerMessage.contains("yes") ||
          lowerMessage.contains("yeah") ||
          lowerMessage.contains("sure")) {
        _addBotMessage("Great! What product are you interested in?");
        _isExitingChat = false;
        _isNegotiationComplete = false;
        _selectedProduct = null;
        _waitingForConfirmation = false;
        _isFirstOffer = true;
        _hasReachedFinalOffer = false;
        return;
      } else if (lowerMessage.contains("no") ||
          lowerMessage.contains("nope") ||
          lowerMessage.contains("not")) {
        _addBotMessage(
          "Thank you for chatting with me today! Have a great day. Closing chat now...",
        );
        // Wait 2 seconds then close the chat
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
        return;
      } else {
        _addBotMessage(
          "I'm not sure if you'd like to browse other products. Please answer with yes or no.",
        );
        return;
      }
    }

    // ENHANCED CATEGORY DETECTION - Check for any form of category mentions
    if (!_isShowingCategoryProducts) {
      // Get all unique categories from products
      Set<String> categories =
          _allProducts.map((p) => p.category.toLowerCase()).toSet();

      // Also look for singular/plural variations of categories
      Map<String, String> categoryVariations = {};
      for (String category in categories) {
        // Handle plural forms
        if (category.endsWith('s')) {
          categoryVariations[category.substring(0, category.length - 1)] =
              category;
        } else {
          categoryVariations[category + 's'] = category;
        }
        categoryVariations[category] = category; // Add the original form too
      }

      // Check if any category is mentioned in the message
      String? matchedCategory;
      for (String variation in categoryVariations.keys) {
        // Look for the category name anywhere in the message
        if (lowerMessage.contains(variation)) {
          matchedCategory = categoryVariations[variation];
          break;
        }
      }

      // Also check for phrases like "show me fruits" or "I want to see fruits"
      if (matchedCategory == null) {
        for (String variation in categoryVariations.keys) {
          if (lowerMessage.contains("show me $variation") ||
              lowerMessage.contains("show $variation") ||
              lowerMessage.contains("see $variation") ||
              lowerMessage.contains("display $variation") ||
              lowerMessage.contains("list $variation")) {
            matchedCategory = categoryVariations[variation];
            break;
          }
        }
      }

      if (matchedCategory != null) {
        _showProductsByCategory(matchedCategory);
        return;
      }
    }

    // Check if user is expressing inability to pay or rejecting the deal
    if ((_waitingForConfirmation || _hasReachedFinalOffer) &&
        (lowerMessage.contains("can't afford") ||
            lowerMessage.contains("cannot afford") ||
            lowerMessage.contains("too expensive") ||
            lowerMessage.contains("don't want") ||
            lowerMessage.contains("do not want") ||
            lowerMessage.contains("not interested") ||
            (lowerMessage.contains("more than") &&
                _extractPrice(userMessage) != null))) {
      _isNegotiationComplete = true;
      _waitingForConfirmation = false;
      _isExitingChat = true;

      _addBotMessage(
        "I understand this doesn't work for you. Would you like to look at other products instead?",
      );
      return;
    }

    // Handle yes/no responses for purchase confirmation
    if (_waitingForConfirmation) {
      String response = userMessage.toLowerCase().trim();
      if (response == 'yes' ||
          response == 'sure' ||
          response == 'okay' ||
          response == 'ok') {
        _waitingForConfirmation = false;
        _isNegotiationComplete = true;

        // Ensure we're using the last offered price from the bot
        _addBotMessage(
          "Great! Your purchase is confirmed at \$${_lastOfferedPrice!.toStringAsFixed(2)}. Thank you for shopping with us!",
        );
        return;
      } else if (response == 'no' || response == 'nope' || response == 'pass') {
        // User rejected our counter offer, so we ask for their new offer
        _waitingForConfirmation = false;
        _addBotMessage(
          "I understand. What price would you like to offer instead?",
        );
        return;
      } else {
        // Try to extract a price from their response
        double? newOfferedPrice = _extractPrice(userMessage);
        if (newOfferedPrice != null) {
          _waitingForConfirmation = false;
          // They responded with a price instead of yes/no
          _handlePriceOffer(newOfferedPrice);
          return;
        } else {
          // Couldn't understand their response
          _waitingForConfirmation = false;
          _addBotMessage(
            "I'm not sure if that's a yes or no. Please provide a clear response or a new price offer.",
          );
          return;
        }
      }
    }

    // If negotiation is complete, don't process any more offers
    if (_isNegotiationComplete) {
      _addBotMessage(
        "Our deal is already complete at \$${_lastOfferedPrice!.toStringAsFixed(2)}. Would you like to negotiate for a different product?",
      );
      return;
    }

    double? offeredPrice = _extractPrice(userMessage);
    if (offeredPrice == null) {
      _addBotMessage(
        "I'm sorry, I couldn't understand your price. Please specify an amount (e.g., \$50).",
      );
      return;
    }

    _handlePriceOffer(offeredPrice);
  }

  // New helper method to separate the price negotiation logic
  void _handlePriceOffer(double offeredPrice) {
    double currentPrice = _currentPrice ?? widget.productPrice;
    double minimumPrice = currentPrice * 0.75; // Absolute minimum (75%)

    // Early return if offered price is higher than current price
    if (offeredPrice >= currentPrice) {
      _addBotMessage(
        "The current price is already \$${currentPrice.toStringAsFixed(2)}. No need to pay more!",
      );
      return;
    }

    // First offer from user
    if (_isFirstOffer) {
      _isFirstOffer = false;

      if (offeredPrice >= minimumPrice) {
        // Good first offer - counter with 10% more than their offer
        double counterOffer = offeredPrice * 1.1;
        if (counterOffer > currentPrice) counterOffer = currentPrice;

        _lastOfferedPrice = counterOffer;
        _addBotMessage(
          "Thanks for your offer of \$${offeredPrice.toStringAsFixed(2)}. "
          "How about \$${counterOffer.toStringAsFixed(2)}? This is a fair price considering the quality.",
        );
        _waitingForConfirmation = true;
      } else {
        // Low first offer - counter with minimum price
        double counterOffer = currentPrice * 0.85; // First counter is 85%
        _lastOfferedPrice = counterOffer;
        _addBotMessage(
          "I appreciate your offer of \$${offeredPrice.toStringAsFixed(2)}, but it's too low. "
          "I can offer \$${counterOffer.toStringAsFixed(2)}, which is already ${(100 - (counterOffer / currentPrice * 100)).toStringAsFixed(0)}% off the regular price.",
        );
        _waitingForConfirmation = true;
      }
      return;
    }

    // Second or later offer
    if (_hasReachedFinalOffer) {
      if (offeredPrice >= _lastOfferedPrice!) {
        _addBotMessage(
          "Perfect! I accept your offer of \$${offeredPrice.toStringAsFixed(2)}. Would you like to proceed with the purchase?",
        );
        _lastOfferedPrice = offeredPrice;
        _waitingForConfirmation = true;
        _isNegotiationComplete = true;
      } else {
        _addBotMessage(
          "I'm sorry, but my final offer is \$${_lastOfferedPrice!.toStringAsFixed(2)}. I cannot go any lower than this. Do you accept this price?",
        );
        _waitingForConfirmation = true;
      }
      return;
    }

    // Not first offer, not final offer yet
    if (offeredPrice >= minimumPrice) {
      if (offeredPrice >= _lastOfferedPrice!) {
        // They increased their offer (unusual but possible)
        _addBotMessage(
          "I appreciate your increased offer of \$${offeredPrice.toStringAsFixed(2)}! I'll happily accept this price. Shall we proceed with the purchase?",
        );
        _lastOfferedPrice = offeredPrice;
        _waitingForConfirmation = true;
        _isNegotiationComplete = true;
      } else {
        // They've made a reasonable counter to our counter
        double finalOffer = (offeredPrice + minimumPrice) / 2;
        _lastOfferedPrice = finalOffer;
        _hasReachedFinalOffer = true;
        _addBotMessage(
          "You're a good negotiator! My final offer is \$${finalOffer.toStringAsFixed(2)}. This is the best I can do. Do we have a deal?",
        );
        _waitingForConfirmation = true;
      }
    } else {
      // They're still offering below minimum price
      _hasReachedFinalOffer = true;
      _lastOfferedPrice = minimumPrice;
      _addBotMessage(
        "I understand you want a good deal, but \$${minimumPrice.toStringAsFixed(2)} is my absolute final offer. "
        "This is ${(100 - (minimumPrice / currentPrice * 100)).toStringAsFixed(0)}% off the regular price. "
        "I cannot go any lower. Do you accept?",
      );
      _waitingForConfirmation = true;
    }
  }

  double? _extractPrice(String message) {
    RegExp regex = RegExp(r'\$?(\d+\.?\d*)');
    Match? match = regex.firstMatch(message);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  // Update the _showProductsByCategory method for better formatting
  void _showProductsByCategory(String category) {
    // Find products matching the category (case insensitive)
    List<Product> categoryProducts =
        _allProducts
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();

    if (categoryProducts.isEmpty) {
      _addBotMessage("I couldn't find any products in the $category category.");
      return;
    }

    // Add a formatted header
    String formattedCategory = category
        .split(" ")
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(" ");

    // Build message with products in this category
    String productList = categoryProducts
        .take(5) // Show only first 5 matches to avoid long messages
        .map((p) => "\n• ${p.name} - \$${p.price.toStringAsFixed(2)}")
        .join("");

    int totalCount = categoryProducts.length;
    String additional = totalCount > 5 ? " and ${totalCount - 5} more" : "";

    _addBotMessage(
      "Here are products in the $formattedCategory category:$productList$additional\n\n"
      "Which one would you like to negotiate for? Just type the product name.",
    );

    _isShowingCategoryProducts = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DealBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isBotTyping) {
                  return BotTypingIndicator();
                }
                return _messages[index];
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _handleUserMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatMessage({Key? key, required this.message, required this.isBot})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.android, color: Colors.white, size: 18),
              radius: 15,
            ),
          SizedBox(width: isBot ? 8 : 0),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isBot ? Colors.grey[200] : Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              message,
              style: TextStyle(color: isBot ? Colors.black87 : Colors.white),
            ),
          ),
          SizedBox(width: isBot ? 0 : 8),
          if (!isBot)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[700], size: 18),
              radius: 15,
            ),
        ],
      ),
    );
  }
}

// Replace the BotTypingIndicator class with this animated version

class BotTypingIndicator extends StatefulWidget {
  @override
  _BotTypingIndicatorState createState() => _BotTypingIndicatorState();
}

class _BotTypingIndicatorState extends State<BotTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();

    // Create animations for each dot with different delays
    for (int i = 0; i < 3; i++) {
      final begin = 0.0;
      final end = 1.0;
      final curve = Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut);

      _animations.add(
        Tween<double>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(parent: _controller, curve: curve)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.android, color: Colors.white, size: 18),
            radius: 15,
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, -4 * _animations[index].value + 2),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[400],
                          radius: 3.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This assumes your Product model exists in the appropriate file
// filepath: d:\Programming\Web Development\Deal Hive\application\lib\Models\product.dart

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
      // Handle price as either string or number
      price:
          json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] ?? 0.0).toDouble(),
      imageLink: json['imageLink'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
