import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double borderRadius;

  const CategoryChip({
    super.key,
    required this.text,
    this.selected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    this.fontSize = 12,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 3),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? HurColors.accent : HurColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: selected ? HurColors.accent : HurColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? HurColors.onAccent : HurColors.text,
          ),
        ),
      ),
    );
  }
}
