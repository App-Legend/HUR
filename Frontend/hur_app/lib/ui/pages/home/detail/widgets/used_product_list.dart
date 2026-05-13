import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:material_symbols_icons/symbols.dart';

class UsedProductList extends StatelessWidget {
  final VoidCallback onOpenTap;

  const UsedProductList({super.key, required this.onOpenTap});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'imagePath': 'assets/images/ranking/ranking4.jpg',
        'brandName': '얼터너티브스테레오',
        'productName': '립 포션 카라멜 글레이즈',
        'price': '18,900원~',
      },
      {
        'imagePath': 'assets/images/ranking/ranking5.jpg',
        'brandName': '얼터너티브스테레오',
        'productName': '립 포션 카라멜 글레이즈',
        'price': '18,900원~',
      },
      {
        'imagePath': 'assets/images/ranking/ranking6.jpg',
        'brandName': '얼터너티브스테레오',
        'productName': '립 포션 카라멜 글레이즈',
        'price': '18,900원~',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductItemContainer(
          imagePath: product['imagePath']!,
          brandName: product['brandName']!,
          productName: product['productName']!,
          price: product['price']!,
          onOpenTap: onOpenTap,
          trailingIcon: Symbols.more_horiz,
        );
      },
    );
  }
}
