import 'package:flutter/material.dart';

class SearchResultCosmeticsTab extends StatelessWidget {
  const SearchResultCosmeticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'brand': '얼터너티브스테레오', 'name': '립 포션 카라멜 글레이즈'},
      {'brand': '퀵', 'name': '로즈 옵세션 스테이핏 틴트'},
      {'brand': '헤라', 'name': '센슈얼 누드 글로스'},
      {'brand': '얼터너티브스테레오', 'name': '립 포션 카라멜 글레이즈'},
      {'brand': '퀵', 'name': '로즈 옵세션 스테이핏 틴트'},
      {'brand': '헤라', 'name': '센슈얼 누드 글로스'},
      {'brand': '얼터너티브스테레오', 'name': '립 포션 카라멜 글레이즈'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _CosmeticsItem(
          rank: index + 1,
          brand: products[index]['brand']!,
          name: products[index]['name']!,
        );
      },
    );
  }
}

class _CosmeticsItem extends StatelessWidget {
  final int rank;
  final String brand;
  final String name;

  const _CosmeticsItem({
    required this.rank,
    required this.brand,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xfff0e8f0),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff9b9b9b),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: Color(0xffbdbdbd), size: 20),
        ],
      ),
    );
  }
}
