import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RankingMorePopup extends StatelessWidget {
  final String imagePath;
  final String brand;
  final String name;

  const RankingMorePopup({
    super.key,
    required this.imagePath,
    required this.brand,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -46,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  imagePath,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close, size: 28, color: Colors.black54),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  brand,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 28),

                _MoreMenuItem(
                  icon: Symbols.keyboard_double_arrow_down,
                  text: '내 화장품',
                  onTap: () {},
                ),
                _MoreMenuItem(
                  icon: Symbols.star_border,
                  text: '찜하기',
                  onTap: () {},
                ),
                _MoreMenuItem(
                  icon: Symbols.heart_plus,
                  text: '유사한 화장품 더 보기',
                  onTap: () {},
                ),
                _MoreMenuItem(
                  icon: Symbols.heart_minus,
                  text: '유사한 화장품 덜 보기',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 14),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
