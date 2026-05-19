import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/common/widget/product_more_popup.dart';
import 'package:hur_app/ui/pages/ranking/detail_ranking_page.dart';

class SearchResultCosmeticsTab extends StatelessWidget {
  const SearchResultCosmeticsTab({super.key});

  static const _products = [
    {
      'rank': '1',
      'brand': '얼터너티브스테레오',
      'name': '립 포션 카라멜 글레이즈',
      'price': '18,000원',
      'image': 'assets/images/ranking/rank1.png',
    },
    {
      'rank': '2',
      'brand': '퀵',
      'name': '로즈 옵세션 스테이핏 틴트',
      'price': '15,000원',
      'image': 'assets/images/ranking/rank2.png',
    },
    {
      'rank': '3',
      'brand': '헤라',
      'name': '센슈얼 누드 글로스',
      'price': '32,000원',
      'image': 'assets/images/ranking/rank3.png',
    },
    {
      'rank': '4',
      'brand': '얼터너티브스테레오',
      'name': '립 포션 카라멜 글레이즈',
      'price': '18,000원',
      'image': 'assets/images/ranking/rank1.png',
    },
    {
      'rank': '5',
      'brand': '퀵',
      'name': '로즈 옵세션 스테이핏 틴트',
      'price': '15,000원',
      'image': 'assets/images/ranking/rank2.png',
    },
    {
      'rank': '6',
      'brand': '헤라',
      'name': '센슈얼 누드 글로스',
      'price': '32,000원',
      'image': 'assets/images/ranking/rank3.png',
    },
    {
      'rank': '7',
      'brand': '얼터너티브스테레오',
      'name': '립 포션 카라멜 글레이즈',
      'price': '18,000원',
      'image': 'assets/images/ranking/rank1.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        return ProductItemContainer(
          rank: p['rank'],
          imagePath: p['image']!,
          brandName: p['brand']!,
          productName: p['name']!,
          price: p['price']!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailRankingPage(
                rank: p['rank']!,
                imagePath: p['image']!,
                brand: p['brand']!,
                name: p['name']!,
              ),
            ),
          ),
          onOpenTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.25),
            isScrollControlled: true,
            builder: (_) => ProductMorePopup(
              imagePath: p['image']!,
              brand: p['brand']!,
              name: p['name']!,
            ),
          ),
        );
      },
    );
  }
}
