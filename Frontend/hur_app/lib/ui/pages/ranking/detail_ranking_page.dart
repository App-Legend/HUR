import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/pages/home/detail/popup/purchase_popup.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DetailRankingPage extends StatefulWidget {
  final String rank;
  final String imagePath;
  final String brand;
  final String name;

  const DetailRankingPage({
    super.key,
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
  });

  @override
  State<DetailRankingPage> createState() => _DetailRankingPageState();
}

class _DetailRankingPageState extends State<DetailRankingPage> {
  String selectedCategory = '전체';
  String selectedTab = '사진';

  void _showPurchasePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      isScrollControlled: true,
      builder: (context) {
        return const PurchasePopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/ranking/detail1.jpg',
      'assets/images/ranking/detail2.jpg',
      'assets/images/ranking/detail3.jpg',
      'assets/images/ranking/detail4.jpg',
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
            MainHeader(
              title: widget.name,
              titleFontSize: 22,
              subtitle: widget.brand,
              subtitleAbove: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              showDivider: false,
              padding: const EdgeInsets.fromLTRB(8, 18, 16, 0),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    //텍스트 주변을 눌러도 선택 가능
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        selectedTab = '사진';
                      });
                    },
                    child: _TabText(text: '사진', selected: selectedTab == '사진'),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        selectedTab = '후기';
                      });
                    },
                    child: _TabText(text: '후기', selected: selectedTab == '후기'),
                  ),
                ),
              ],
            ),

            Container(height: 1, color: const Color(0xffeeeeee)),

            const SizedBox(height: 12),

            if (selectedTab == '사진') ...[
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CategoryChip(
                      text: '전체',
                      selected: selectedCategory == '전체',
                      onTap: () {
                        setState(() {
                          selectedCategory = '전체';
                        });
                      },
                    ),
                    CategoryChip(
                      text: '봄 웜',
                      selected: selectedCategory == '봄 웜',
                      onTap: () {
                        setState(() {
                          selectedCategory = '봄 웜';
                        });
                      },
                    ),
                    CategoryChip(
                      text: '가을 웜',
                      selected: selectedCategory == '가을 웜',
                      onTap: () {
                        setState(() {
                          selectedCategory = '가을 웜';
                        });
                      },
                    ),
                    CategoryChip(
                      text: '여름 쿨',
                      selected: selectedCategory == '여름 쿨',
                      onTap: () {
                        setState(() {
                          selectedCategory = '여름 쿨';
                        });
                      },
                    ),
                    CategoryChip(
                      text: '겨울 쿨',
                      selected: selectedCategory == '겨울 쿨',
                      onTap: () {
                        setState(() {
                          selectedCategory = '겨울 쿨';
                        });
                      },
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.imagePath,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              widget.rank,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '오늘 조회 3206',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '총 47회 사용',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 30),
                          GestureDetector(
                            onTap: _showPurchasePopup,
                            child: Icon(
                              Symbols.open_in_new,
                              weight: 400,
                              color: Color(0xffbfbfbf),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 6,
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
            ] else ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: const [
                    _ReviewItem(
                      userName: 'user_01',
                      review: '색감이 예쁘고 데일리로 쓰기 좋아요.',
                    ),
                    _ReviewItem(
                      userName: 'user_02',
                      review: '발림성이 부드럽고 광택감이 마음에 들어요.',
                    ),
                    _ReviewItem(
                      userName: 'user_03',
                      review: '생각보다 지속력도 괜찮았습니다.',
                    ),
                  ],
                ),
              ),
            ],
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

class _ReviewItem extends StatelessWidget {
  final String userName;
  final String review;

  const _ReviewItem({required this.userName, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
