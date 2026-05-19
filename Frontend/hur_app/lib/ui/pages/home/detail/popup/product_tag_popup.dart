//  ————————————————————————————————
//  |    이미지에 태그된 제품 팝업    |
//  ————————————————————————————————

import 'package:flutter/material.dart';

class ProductTagPopup extends StatelessWidget {
  final String imagePath;
  final String brandName;
  final String productName;
  final String price;

  const ProductTagPopup({
    super.key,
    required this.imagePath,
    required this.brandName,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xffbbbbbb), fontSize: 8),
                ),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
