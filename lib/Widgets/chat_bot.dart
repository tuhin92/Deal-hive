import 'package:flutter/material.dart';

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

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! I'm DealBot. I see you're interested in ${widget.productName}. "
      "The current price is \$${widget.productPrice.toStringAsFixed(2)}. "
      "What price would you like to negotiate for?",
    );
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
      _processBotResponse(message);
    });
  }

  void _processBotResponse(String userMessage) {
    // Extract number from user message
    double? offeredPrice = _extractPrice(userMessage);
    String botResponse;

    if (offeredPrice == null) {
      botResponse =
          "I'm sorry, I couldn't understand the price. Please mention a specific amount.";
    } else {
      double minimumPrice = widget.productPrice * 0.7; // 70% of original price

      if (offeredPrice >= widget.productPrice) {
        botResponse =
            "The current price is already \$${widget.productPrice.toStringAsFixed(2)}. No need to pay more!";
      } else if (offeredPrice >= minimumPrice) {
        botResponse =
            "Great! I can accept your offer of \$${offeredPrice.toStringAsFixed(2)}. Would you like to proceed with the purchase?";
      } else {
        botResponse =
            "I'm sorry, I cannot go that low. The minimum price I can offer is \$${minimumPrice.toStringAsFixed(2)}.";
      }
    }

    setState(() {
      _isBotTyping = false;
      _addBotMessage(botResponse);
    });
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
