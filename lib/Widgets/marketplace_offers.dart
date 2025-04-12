import 'package:flutter/material.dart';

class MarketplaceOffers extends StatelessWidget {
  const MarketplaceOffers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Marketplace Offers header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Marketplace Offers",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "See All",
                style: TextStyle(color: Colors.black45, fontSize: 16),
              ),
            ],
          ),
        ),

        // Marketplace Offers cards
        Container(
          height: 180,
          padding: EdgeInsets.only(left: 20),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMarketplaceOffer(
                storeName: "TechBay",
                productName: "Wireless Earbuds",
                originalPrice: 89.99,
                offerPrice: 59.99,
                discount: 33,
                imageUrl:
                    "https://images.unsplash.com/photo-1605464315542-bda3e2f4e605?q=80&w=200",
                storeColor: Colors.blue[700]!,
              ),
              _buildMarketplaceOffer(
                storeName: "FashionHub",
                productName: "Leather Jacket",
                originalPrice: 199.99,
                offerPrice: 149.99,
                discount: 25,
                imageUrl:
                    "https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=200",
                storeColor: Colors.orange[700]!,
              ),
              _buildMarketplaceOffer(
                storeName: "HomeDecor",
                productName: "Smart Light Set",
                originalPrice: 79.99,
                offerPrice: 49.99,
                discount: 38,
                imageUrl:
                    "https://images.unsplash.com/photo-1573511860302-28c524319d2a?q=80&w=200",
                storeColor: Colors.green[700]!,
              ),
              _buildMarketplaceOffer(
                storeName: "SportZone",
                productName: "Fitness Tracker",
                originalPrice: 129.99,
                offerPrice: 79.99,
                discount: 40,
                imageUrl:
                    "https://images.unsplash.com/photo-1576243345690-4e4b79b63288?q=80&w=200",
                storeColor: Colors.red[700]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceOffer({
    required String storeName,
    required String productName,
    required double originalPrice,
    required double offerPrice,
    required int discount,
    required String imageUrl,
    required Color storeColor,
  }) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: storeColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$discount% OFF",
                    style: TextStyle(
                      color: storeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Icon(Icons.error, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "\$${offerPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: storeColor,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "\$${originalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Limited time offer",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                "View Deal",
                style: TextStyle(
                  color: storeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
