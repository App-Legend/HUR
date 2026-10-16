//  ————————————————————————————————
//  | 제품 태그/공개 대상 row 컴포넌트 |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class UploadMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const UploadMenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: HurColors.text),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HurColors.text,
            ),
          ),
          const Spacer(),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(fontSize: 12, color: HurColors.muted),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 30, color: HurColors.text),
        ],
      ),
    );
  }
}
