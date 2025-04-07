import 'package:application/Widgets/banner.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  Widget _buildCategoryItem(String imageUrl, String categoryName) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
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
              return Icon(Icons.error, size: 40);
            },
          ),
          SizedBox(height: 8),
          Text(
            categoryName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            // header part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/logo.png", height: 40),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Iconsax.shopping_bag, size: 28),
                      Positioned(
                        right: -3,
                        top: -5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "2",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // for banner part
            MyBanner(),

            // shop by category part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shop by Category",
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

            // category items part
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3194/3194766.png",
                      "Fruits",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3075/3075975.png",
                      "Fish",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3004/3004458.png",
                      "Medicine",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/1005/1005665.png",
                      "Beauty",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/3659/3659899.png",
                      "Electronics",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/2331/2331966.png",
                      "Clothing",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/1830/1830847.png",
                      "Home & Kitchen",
                    ),
                    _buildCategoryItem(
                      "https://cdn-icons-png.flaticon.com/512/857/857418.png",
                      "Sports & Outdoors",
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
