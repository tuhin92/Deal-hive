import 'package:flutter/material.dart';
import 'package:application/Models/product.dart';
import 'package:application/Widgets/product_item.dart';
import 'package:application/Widgets/section_header.dart';

class ProductsSection extends StatelessWidget {
  final List<Product?> products;
  final bool isLoading;
  final String errorMessage;
  final String sectionTitle;

  const ProductsSection({
    Key? key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.sectionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SectionHeader(title: sectionTitle, onSeeAllPressed: () {}),
        ),
        _buildProductsList(),
      ],
    );
  }

  Widget _buildProductsList() {
    if (isLoading) {
      return Container(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        height: 230,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(errorMessage, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (products.isEmpty) {
      return Container(
        height: 230,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: Text('No products available')),
      );
    }

    return Container(
      height: 230,
      padding: EdgeInsets.only(left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          if (products[index] == null) return SizedBox.shrink();
          return ProductItem(product: products[index]!);
        },
      ),
    );
  }
}
