import 'package:flutter/material.dart';

class PaymentOptionsBanner extends StatelessWidget {
  const PaymentOptionsBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Payment options data with icons, text and background colors
    final List<Map<String, dynamic>> paymentOptions = [
      {
        'icon': Icons.credit_card,
        'text': 'Pay with Card',
        'subtext': 'Get 10% off',
        'color': Color(0xFFE3F2FD),
        'iconColor': Colors.blue,
      },
      {
        'icon': Icons.account_balance_wallet,
        'text': 'EMI Available',
        'subtext': 'No cost EMI',
        'color': Color(0xFFF3E5F5),
        'iconColor': Colors.purple,
      },
      {
        'icon': Icons.currency_exchange,
        'text': 'Cashback',
        'subtext': 'Up to \$50',
        'color': Color(0xFFE8F5E9),
        'iconColor': Colors.green,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              "Payment Options",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: paymentOptions.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: paymentOptions[index]['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to payment details or apply promo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${paymentOptions[index]['text']} selected",
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              paymentOptions[index]['icon'],
                              color: paymentOptions[index]['iconColor'],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  paymentOptions[index]['text'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  paymentOptions[index]['subtext'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
