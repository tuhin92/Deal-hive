import 'package:application/utils/coloers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MyBanner extends StatefulWidget {
  const MyBanner({super.key});

  @override
  State<MyBanner> createState() => _MyBannerState();
}

class _MyBannerState extends State<MyBanner> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<BannerData> _bannerItems = [
    BannerData(
      title: "Fresh Fruits",
      subtitle: "Organic Collection",
      discount: "20",
      tagline: "FRESH PICKS",
      imageUrl:
          "https://images.unsplash.com/photo-1610832958506-aa56368176cf?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFF4CAF50),
    ),
    BannerData(
      title: "Spring Fashion",
      subtitle: "Trendy Collection",
      discount: "30",
      tagline: "NEW ARRIVALS",
      imageUrl:
          "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFFFF6E40),
    ),
    BannerData(
      title: "Beauty Products",
      subtitle: "Luxury Collection",
      discount: "35",
      tagline: "SELF CARE",
      imageUrl:
          "https://images.unsplash.com/photo-1596462502278-27bfdc403348?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFFE91E63),
    ),
    BannerData(
      title: "Fresh Seafood",
      subtitle: "Ocean Collection",
      discount: "22",
      tagline: "CATCH OF THE DAY",
      imageUrl:
          "https://images.unsplash.com/photo-1579756423478-02bc82a97089?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFF03A9F4),
    ),
    BannerData(
      title: "Sports Gear",
      subtitle: "Athletic Collection",
      discount: "25",
      tagline: "GET FIT",
      imageUrl:
          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFF2196F3),
    ),
    BannerData(
      title: "Health Essentials",
      subtitle: "Wellness Collection",
      discount: "15",
      tagline: "STAY HEALTHY",
      imageUrl:
          "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=720&q=80",
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-rotate banner every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _bannerItems.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var currentBanner = _bannerItems[_currentIndex];

    return Container(
      height: size.height * 0.25,
      width: size.width,
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background gradient overlay
            Positioned.fill(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF212121).withOpacity(0.9),
                      currentBanner.color.withOpacity(0.3),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Model/Product image positioned on the right with fade animation
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Image.network(
                    currentBanner.imageUrl,
                    key: ValueKey<String>(currentBanner.imageUrl),
                    height: double.infinity,
                    width: size.width * 0.6,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: size.width * 0.6,
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Text content column with fade animation
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey<int>(_currentIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: currentBanner.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              currentBanner.tagline,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            currentBanner.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentBanner.discount,
                                style: TextStyle(
                                  fontSize: 50,
                                  height: 0.9,
                                  fontWeight: FontWeight.bold,
                                  color: currentBanner.color,
                                ),
                              ),
                              SizedBox(width: 2),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: currentBanner.color,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    "OFF",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
                                      height: 0.8,
                                      color: currentBanner.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentBanner.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "SHOP NOW",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Space for the image to show through
                  SizedBox(width: size.width * 0.28),
                ],
              ),
            ),

            // Category indicators
            Positioned(
              bottom: 8,
              left: 24,
              child: Row(
                children: List.generate(_bannerItems.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index
                              ? _bannerItems[index].color
                              : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerData {
  final String title;
  final String subtitle;
  final String discount;
  final String tagline;
  final String imageUrl;
  final Color color;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.tagline,
    required this.imageUrl,
    required this.color,
  });
}
