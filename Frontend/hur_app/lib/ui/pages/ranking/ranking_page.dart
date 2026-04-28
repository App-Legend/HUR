import 'package:flutter/material.dart';

import 'detail_ranking_page.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      ['4', 'assets/images/ranking/rank4.jpg', '얼터너티브스테레오', '립 포션 카라멜 글레이즈'],
      ['5', 'assets/images/ranking/rank5.jpg', '퓌', '로즈 옵세션 스테이핏 틴트'],
      ['6', 'assets/images/ranking/rank6.jpg', '헤라', '센슈얼 누드 글로스'],
      ['7', 'assets/images/ranking/rank7.jpg', '롬앤', '글래스팅 컬러 글로스'],
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 15, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 추구미 랭킹',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '피드 기반으로 측정됩니다',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: const Color(0xffdddddd)),

            const SizedBox(height: 14),

            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  _CategoryChip(text: '틴트', selected: true),
                  _CategoryChip(text: '렌즈'),
                  _CategoryChip(text: '볼터치'),
                  _CategoryChip(text: '섀도우 팔레트'),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 5, 16, 10),
              child: Text(
                'TOP3',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    top: 55,
                    child: _TopImage(
                      imagePath: 'assets/images/ranking/top2.jpg',
                      width: 150,
                      height: 170,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 55,
                    child: _TopImage(
                      imagePath: 'assets/images/ranking/top3.jpg',
                      width: 150,
                      height: 170,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: _TopImage(
                      imagePath: 'assets/images/ranking/top1.jpg',
                      width: 255,
                      height: 210,
                    ),
                  ),
                ],
              ),
            ),

            const Center(
              child: Text(
                '•  •  •',
                style: TextStyle(
                  fontSize: 24,
                  letterSpacing: 5,
                  color: Colors.black,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                'TOP20',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailRankingPage(),
                        ),
                      );
                    },
                    child: _RankingItem(
                      rank: item[0],
                      imagePath: item[1],
                      brand: item[2],
                      name: item[3],
                    ),
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

class _CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;

  const _CategoryChip({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffcfcfcf) : const Color(0xfff3f3f3),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black),
      ),
    );
  }
}

class _TopImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const _TopImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffeeeeee),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final String rank;
  final String imagePath;
  final String brand;
  final String name;

  const _RankingItem({
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xffefc6f2),
            child: Text(
              rank,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xffeab5ec),
            child: Icon(Icons.check, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
