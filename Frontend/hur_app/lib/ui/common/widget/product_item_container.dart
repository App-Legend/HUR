import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// imagePath가 'http'로 시작하면 NetworkImage, 아니면 AssetImage 사용
Widget _productImage(String imagePath, {double? width, double? height}) {
  final fit = BoxFit.cover;
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
      ),
    );
  }
  return Image.asset(imagePath, width: width, height: height, fit: fit);
}

class ProductItemContainer extends StatelessWidget {
  final String? rank;
  final String imagePath;
  final String brandName;
  final String productName;
  final String price;
  final VoidCallback? onTap;
  final VoidCallback onOpenTap;
  final IconData? trailingIcon;

  const ProductItemContainer({
    super.key,
    this.trailingIcon,
    this.rank,
    required this.imagePath,
    required this.brandName,
    required this.productName,
    required this.price,
    required this.onOpenTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (rank != null) ...[
            Text(
              rank!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 14),
          ],

          const SizedBox(width: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _productImage(imagePath, width: 52, height: 52),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandName,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  productName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpenTap,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Symbols.more_horiz,
                  size: 24,
                  color: Colors.black,
                  weight: 400,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
