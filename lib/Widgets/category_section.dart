import 'package:flutter/material.dart';
import 'package:application/Widgets/category_item.dart';
import 'package:application/Widgets/section_header.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SectionHeader(
            title: "Shop by Category",
            onSeeAllPressed: () {},
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3194/3194766.png",
                  categoryName: "Fruits",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3075/3075975.png",
                  categoryName: "Fish",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3004/3004458.png",
                  categoryName: "Medicine",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/1005/1005665.png",
                  categoryName: "Beauty",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/3659/3659899.png",
                  categoryName: "Electronics",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/2331/2331966.png",
                  categoryName: "Clothing",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/1830/1830847.png",
                  categoryName: "Home & Kitchen",
                ),
                CategoryItem(
                  imageUrl:
                      "https://cdn-icons-png.flaticon.com/512/857/857418.png",
                  categoryName: "Sports & Outdoors",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
