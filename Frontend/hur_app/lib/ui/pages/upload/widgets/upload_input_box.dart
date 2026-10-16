//  ————————————————————————————————
//  |        제목/설명 작성란         |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class UploadInputBox extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  final int maxLines;

  const UploadInputBox({
    super.key,
    required this.controller,
    this.height = 40,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: HurColors.text, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: HurColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: HurColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: HurColors.border),
          ),
        ),
      ),
    );
  }
}
