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

  @override
  void initState() {
    super.initState();
    if (widget.productName == "our products") {
      _fetchProducts(); // Fetch products when starting from home screen
      _addBotMessage(
        "Hello! I'm DealBot. Which product are you interested in buying? Please enter the product name.",
      );
    } else {
      _selectedProduct = widget.productName;
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

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isBot: true));
    });
  }

  void _handleUserMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(message: message, isBot: false));
      _messageController.clear();
      _isBotTyping = true;
    });

    // Simulate bot thinking
    Future.delayed(Duration(seconds: 1), () {
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

  // Update the _processBotResponse method to fix the negotiation logic
  void _processBotResponse(String userMessage) {
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

class BotTypingIndicator extends StatelessWidget {
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
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    radius: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
