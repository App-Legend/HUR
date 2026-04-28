import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController? searchController;
  final VoidCallback? onSearchTap;

  const HomeHeader({super.key, this.searchController, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hur',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: searchController,
            onTap: onSearchTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff1f1f1),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 26,
              ),
              hintText: '제품, 브랜드, 메이크업 검색...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
