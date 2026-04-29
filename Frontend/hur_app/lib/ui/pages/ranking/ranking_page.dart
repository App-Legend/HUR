import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'detail_ranking_page.dart';

class RankingProduct {
  final String rank;
  final String imagePath;
  final String brand;
  final String name;

  const RankingProduct({
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
  });

  factory RankingProduct.fromList(List<String> data) {
    return RankingProduct(
      rank: data[0],
      imagePath: data[1],
      brand: data[2],
      name: data[3],
    );
  }
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String selectedCategory = '틴트';

  @override
  Widget build(BuildContext context) {
    final productsData = [
      ['4', 'assets/images/ranking/rank4.jpg', '얼터너티브스테레오', '립 포션 카라멜 글레이즈'],
      ['5', 'assets/images/ranking/rank5.jpg', '퓌', '로즈 옵세션 스테이핏 틴트'],
      ['6', 'assets/images/ranking/rank6.jpg', '헤라', '센슈얼 누드 글로스'],
      ['7', 'assets/images/ranking/rank7.jpg', '롬앤', '글래스팅 컬러 글로스'],
    ];

    final top3Data = [
      ['1', 'assets/images/ranking/rank1.png', '랭킹 1위 브랜드', '랭킹 1위 제품'],
      ['2', 'assets/images/ranking/rank2.png', '랭킹 2위 브랜드', '랭킹 2위 제품'],
      ['3', 'assets/images/ranking/rank3.png', '랭킹 3위 브랜드', '랭킹 3위 제품'],
    ];

    final products = productsData
        .map((e) => RankingProduct.fromList(e))
        .toList();
    final top3 = top3Data.map((e) => RankingProduct.fromList(e)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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

                  // ✅ CategoryChip 영역
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        CategoryChip(
                          text: '틴트',
                          selected: selectedCategory == '틴트',
                          onTap: () {
                            setState(() {
                              selectedCategory = '틴트';
                            });
                          },
                        ),
                        CategoryChip(
                          text: '렌즈',
                          selected: selectedCategory == '렌즈',
                          onTap: () {
                            setState(() {
                              selectedCategory = '렌즈';
                            });
                          },
                        ),
                        CategoryChip(
                          text: '볼터치',
                          selected: selectedCategory == '볼터치',
                          onTap: () {
                            setState(() {
                              selectedCategory = '볼터치';
                            });
                          },
                        ),
                        CategoryChip(
                          text: '섀도우 팔레트',
                          selected: selectedCategory == '섀도우 팔레트',
                          onTap: () {
                            setState(() {
                              selectedCategory = '섀도우 팔레트';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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
                          child: GestureDetector(
                            onTap: () => _goToDetail(context, top3[1]),
                            child: _TopImage(
                              imagePath: top3[1].imagePath,
                              width: 130,
                              height: 160,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 55,
                          child: GestureDetector(
                            onTap: () => _goToDetail(context, top3[2]),
                            child: _TopImage(
                              imagePath: top3[2].imagePath,
                              width: 130,
                              height: 160,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _goToDetail(context, top3[0]),
                            child: _TopImage(
                              imagePath: top3[0].imagePath,
                              width: 220,
                              height: 200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Center(
                    child: Text(
                      '•  •  •',
                      style: TextStyle(fontSize: 24, letterSpacing: 5),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = products[index];

                  return GestureDetector(
                    onTap: () => _goToDetail(context, item),
                    child: _RankingItem(
                      rank: item.rank,
                      imagePath: item.imagePath,
                      brand: item.brand,
                      name: item.name,
                    ),
                  );
                }, childCount: products.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(BuildContext context, RankingProduct item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailRankingPage(
          rank: item.rank,
          imagePath: item.imagePath,
          brand: item.brand,
          name: item.name,
        ),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
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
            radius: 14,
            backgroundColor: const Color(0xffefc6f2),
            child: Text(rank, style: TextStyle(color: Colors.purple)),
          ),
          const SizedBox(width: 6),
          Image.asset(imagePath, width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: const TextStyle(color: Colors.black)),
                Text(name, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
