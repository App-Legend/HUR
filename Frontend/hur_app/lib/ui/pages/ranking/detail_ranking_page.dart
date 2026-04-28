import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/detail_ranking_header.dart';

class DetailRankingPage extends StatelessWidget {
  final String brand;
  final String productName;

  const DetailRankingPage({
    super.key,
    required this.brand,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/ranking/detail1.jpg',
      'assets/images/ranking/detail2.jpg',
      'assets/images/ranking/detail3.jpg',
      'assets/images/ranking/detail4.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            DetailRankingHeader(brand: brand, productName: productName),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(child: _TabText(text: '사진', selected: true)),
                Expanded(child: _TabText(text: '후기', selected: false)),
              ],
            ),

            Container(height: 1, color: const Color(0xffeeeeee)),

            const SizedBox(height: 12),

            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: const [
                  _ToneChip(text: '전체', selected: true),
                  _ToneChip(text: '봄 웜'),
                  _ToneChip(text: '가을 웜'),
                  _ToneChip(text: '여름 쿨'),
                  _ToneChip(text: '겨울 쿨'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 18),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/ranking/rank6.jpg',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 18),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xffefc6f2),
                    child: Text(
                      '6',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘 조회 3206',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '총 47회 사용',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(images[index], fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  final bool selected;

  const _TabText({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.purple : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          color: selected ? Colors.purple : Colors.transparent,
        ),
      ],
    );
  }
}

class _ToneChip extends StatelessWidget {
  final String text;
  final bool selected;

  const _ToneChip({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffcfcfcf) : const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}
