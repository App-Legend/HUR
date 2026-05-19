//  ————————————————————————————————
//  |        태그 가능한 페이지        |
//  ————————————————————————————————

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:material_symbols_icons/symbols.dart';

class UploadProduct {
  final String imagePath;
  final String brand;
  final String name;
  final String price;

  const UploadProduct({
    required this.imagePath,
    required this.brand,
    required this.name,
    this.price = '',
  });
}

const kUploadProducts = [
  UploadProduct(
    imagePath: 'assets/images/ranking/rank1.png',
    brand: '얼터너티브스테레오',
    name: '립 포션 카라멜 글레이즈',
    price: '17,000원',
  ),
  UploadProduct(
    imagePath: 'assets/images/ranking/ranking5.jpg',
    brand: '퓌',
    name: '로즈 옵세션 스테이핏 틴트',
    price: '18,000원',
  ),
  UploadProduct(
    imagePath: 'assets/images/ranking/ranking7.jpg',
    brand: '헤라',
    name: '센슈얼 누드 글로스',
    price: '40,000원',
  ),
];

class ProductTagPage extends StatelessWidget {
  final File? selectedImage;

  const ProductTagPage({super.key, required this.selectedImage});

  void _openAddProductPage() {
    // TODO: 화장품 추가 화면 연결
  }

  void _openProductDetail() {
    // TODO: 제품 상세 페이지 연결
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 34,
                        color: Colors.black,
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      '화장품 태그',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff9c27b0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(height: 1, color: const Color(0xffdddddd)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: selectedImage == null
                          ? const SizedBox()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),

                    const SizedBox(height: 22),

                    //이미지에 태그 추가하는 기능은 일단 보류
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _openAddProductPage,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xffd9d9d9),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '화장품 추가',
                          style: TextStyle(fontSize: 11, color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      '등록된 화장품',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    for (int i = 0; i < kUploadProducts.length; i++) ...[
                      ProductItemContainer(
                        imagePath: kUploadProducts[i].imagePath,
                        brandName: kUploadProducts[i].brand,
                        productName: kUploadProducts[i].name,
                        price: '',
                        trailingIcon: Symbols.more_horiz,
                        onOpenTap: _openProductDetail,
                      ),
                      if (i < kUploadProducts.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
