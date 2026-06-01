import 'package:flutter/material.dart';

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
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.fontSize = 13,
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
          color: selected ? const Color(0xff9c27b0) : const Color(0xfff3f3f3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
