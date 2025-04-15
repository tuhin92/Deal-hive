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
                  icon: Icons.shopping_basket,
                  categoryName: "Fruits",
                ),
                CategoryItem(icon: Icons.set_meal, categoryName: "Fish"),
                CategoryItem(icon: Icons.medication, categoryName: "Medicine"),
                CategoryItem(
                  icon: Icons.face_retouching_natural,
                  categoryName: "Beauty",
                ),
                CategoryItem(icon: Icons.devices, categoryName: "Electronics"),
                CategoryItem(icon: Icons.checkroom, categoryName: "Clothing"),
                CategoryItem(icon: Icons.chair, categoryName: "Home & Kitchen"),
                CategoryItem(
                  icon: Icons.sports_basketball,
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
