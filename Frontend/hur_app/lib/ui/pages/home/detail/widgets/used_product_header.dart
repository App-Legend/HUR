//  ————————————————————————————————
//  |  사용한 제품(텍스트/아이콘) 헤더  |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UsedProductHeader extends StatelessWidget {
  final int count;

  const UsedProductHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Symbols.sell, color: Colors.black, size: 25, weight: 400),
        const SizedBox(width: 6),
        const Text(
          '사용한 제품',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffedc8ef),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
