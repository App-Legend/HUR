import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      ['assets/images/search/search1.jpg', '롬앤', '롬앤 쥬시래스팅틴트', '틴트', '8,900원'],
      [
        'assets/images/search/search2.jpg',
        '클리오',
        '클리오 프로 아이 팔레트',
        '아이섀도우',
        '28,000원',
      ],
      [
        'assets/images/search/search3.jpg',
        '페리페라',
        '페리페라 잉크 더 에어리 벨벳',
        '틴트',
        '7,200원',
      ],
      [
        'assets/images/search/search4.jpg',
        '3CE',
        '3CE 무드 레시피 멀티 아이 컬러 팔레트',
        '아이섀도우',
        '35,000원',
      ],
      ['assets/images/search/search5.jpg', '에뛰드', '에뛰드 블러셔', '블러셔', '9,000원'],
      [
        'assets/images/search/search6.jpg',
        '올리브영',
        '올리브영 컬러렌즈',
        '렌즈',
        '15,000원',
      ],
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      body: SafeArea(
        child: Column(
          children: [
            // 검색 창
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff1f1f1),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 34,
                  ),
                  hintText: '제품, 계정, 피드 검색',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            // 메뉴 탭
            Row(
              children: const [
                Expanded(child: _SearchTab(text: '화장품', selected: true)),
                Expanded(child: _SearchTab(text: '계정')),
                Expanded(child: _SearchTab(text: '피드')),
              ],
            ),

            Container(height: 1, color: const Color(0xffdddddd)),

            // TODO: List 내용들 Overflow 발생 (건우)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];

                  return _ProductItem(
                    imagePath: item[0],
                    brand: item[1],
                    name: item[2],
                    category: item[3],
                    price: item[4],
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

class _SearchTab extends StatelessWidget {
  final String text;
  final bool selected;

  const _SearchTab({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 22,
            color: selected ? Colors.purple : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 3,
          color: selected ? Colors.purple : Colors.transparent,
        ),
      ],
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String imagePath;
  final String brand;
  final String name;
  final String category;
  final String price;

  const _ProductItem({
    required this.imagePath,
    required this.brand,
    required this.name,
    required this.category,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              imagePath,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 22),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(fontSize: 23, color: Colors.black54),
                ),

                const SizedBox(height: 8),

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 25, color: Colors.black),
                ),

                const Spacer(),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff4f4f4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 23,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
