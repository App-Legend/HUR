//  ————————————————————————————————
//  |       사용한 제품 리스트        |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/pages/ranking/detail_ranking_page.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hur_app/app/theme.dart';

class UsedProductList extends StatelessWidget {
  final VoidCallback onOpenTap;
  final List<Map<String, dynamic>> stickers;

  const UsedProductList({
    super.key,
    required this.onOpenTap,
    required this.stickers,
  });

  @override
  Widget build(BuildContext context) {
    if (stickers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '사용한 제품이 없습니다',
          style: TextStyle(color: HurColors.muted, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stickers.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final s = stickers[index];
        return ProductItemContainer(
          imagePath: s['image'] as String? ?? '',
          brandName: s['brand_name'] ?? '',
          productName: s['product_name'] ?? '',
          price: '',
          onOpenTap: onOpenTap,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailRankingPage(
                rank: '-',
                imagePath: s['image'] as String? ?? '',
                brand: s['brand_name'] as String? ?? '',
                name: s['product_name'] as String? ?? '',
                productId: s['product_id'] as int?,
              ),
            ),
          ),
          trailingIcon: Symbols.more_horiz,
        );
      },
    );
  }
}
