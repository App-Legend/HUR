//  ————————————————————————————————
//  |    이미지에 태그된 제품 팝업    |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class ProductTagPopup extends StatelessWidget {
  final String brandName;
  final String productName;
  final String imageUrl;

  const ProductTagPopup({
    super.key,
    required this.brandName,
    required this.productName,
    this.imageUrl = '',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              color: Colors.white24,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.face_retouching_natural,
                          color: Colors.white70,
                          size: 20),
                    )
                  : const Icon(Icons.face_retouching_natural,
                      color: Colors.white70, size: 20),
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
                  style: const TextStyle(color: HurColors.muted, fontSize: 8),
                ),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: HurColors.text, fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: HurColors.text, size: 20),
        ],
      ),
    );
  }
}
