//  ————————————————————————————————
//  |    이미지에 태그된 제품 팝업    |
//  ————————————————————————————————

import 'package:flutter/material.dart';

class ProductTagPopup extends StatelessWidget {
  final String brandName;
  final String productName;

  const ProductTagPopup({
    super.key,
    required this.brandName,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.face_retouching_natural,
                color: Colors.white70, size: 20),
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
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
