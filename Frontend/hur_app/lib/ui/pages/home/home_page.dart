import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';

import 'detail_home_page.dart';

// TODO: 타이틀 바와 이미지들 사이 margin 조정 필요 (건우)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final leftImages = [
      'assets/images/home/home1.jpg',
      'AD',
      'assets/images/home/home2.jpg',
      'assets/images/home/home3.jpg',
    ];

    final rightImages = [
      'assets/images/home/home4.jpg',
      'assets/images/home/home5.jpg',
      'assets/images/home/home6.jpg',
      'assets/images/home/home7.jpg',
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 7),
            const MainHeader(
              title: 'Hur',
              titleFontSize: 32,
              padding: EdgeInsets.fromLTRB(18, 14, 18, 8),
              height: 80,
            ),
            Container(
              height: 1,
              color: const Color.fromARGB(255, 206, 206, 206),
            ),
            // 이미지 그리드
            Expanded(
              child: Padding(
                padding: .symmetric(vertical: 12, horizontal: 10),
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: leftImages.map((item) {
                            if (item == 'AD') {
                              return const _AdBox();
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DetailPage(),
                                  ),
                                );
                              },
                              child: _ImageCard(imagePath: item, height: 160),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          children: rightImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DetailPage(),
                                  ),
                                );
                              },
                              child: _ImageCard(
                                imagePath: item,
                                height: index == 0 ? 300 : 130,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final double height;

  const _ImageCard({required this.imagePath, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}

class _AdBox extends StatelessWidget {
  const _AdBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xffd9d9d9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Text(
          'AD',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
