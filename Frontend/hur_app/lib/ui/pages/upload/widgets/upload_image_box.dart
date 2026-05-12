import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class UploadImageBox extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;

  const UploadImageBox({
    super.key,
    required this.selectedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: const Color(0xffcfcfcf),
        strokeWidth: 1.2,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(18),
        child: Container(
          height: 176,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: selectedImage == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 34,
                      color: Color(0xffbbbbbb),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '사진 업로드',
                      style: TextStyle(fontSize: 14, color: Color(0xff777777)),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 176,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
