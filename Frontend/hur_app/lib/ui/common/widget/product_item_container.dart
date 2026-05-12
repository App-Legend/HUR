import 'package:flutter/material.dart';

class ProductItemContainer extends StatelessWidget {
  final String imagePath;
  final String brandName;
  final String productName;
  final String price;
  final VoidCallback onOpenTap;

  const ProductItemContainer({
    super.key,
    required this.imagePath,
    required this.brandName,
    required this.productName,
    required this.price,
    required this.onOpenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandName,
                  style: const TextStyle(
                    color: Color(0xffaaaaaa),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            price,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: onOpenTap,
            child: const Icon(
              Icons.open_in_new,
              color: Color(0xffc9c9c9),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
