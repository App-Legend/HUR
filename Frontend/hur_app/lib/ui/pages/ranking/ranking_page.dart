import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/common/widget/product_more_popup.dart';
import 'detail_ranking_page.dart';

// 랭킹 상품 데이터 모델
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

const _kTop3 = [
  RankingProduct(
    rank: '1',
    imagePath: 'assets/images/ranking/rank1.png',
    brand: '랭킹 1위 브랜드',
    name: '랭킹 1위 제품',
  ),
  RankingProduct(
    rank: '2',
    imagePath: 'assets/images/ranking/rank2.png',
    brand: '랭킹 2위 브랜드',
    name: '랭킹 2위 제품',
  ),
  RankingProduct(
    rank: '3',
    imagePath: 'assets/images/ranking/rank3.png',
    brand: '랭킹 3위 브랜드',
    name: '랭킹 3위 제품',
  ),
];

const _kProducts = [
  RankingProduct(
    rank: '4',
    imagePath: 'assets/images/ranking/ranking4.jpg',
    brand: '얼터너티브스테레오',
    name: '립 포션 카라멜 글레이즈',
  ),
  RankingProduct(
    rank: '5',
    imagePath: 'assets/images/ranking/ranking5.jpg',
    brand: '퓌',
    name: '로즈 옵세션 스테이핏 틴트',
  ),
  RankingProduct(
    rank: '6',
    imagePath: 'assets/images/ranking/ranking6.jpg',
    brand: '헤라',
    name: '센슈얼 누드 글로스',
  ),
  RankingProduct(
    rank: '7',
    imagePath: 'assets/images/ranking/ranking7.jpg',
    brand: '롬앤',
    name: '글래스팅 컬러 글로스',
  ),
];

// 전체 랭킹 페이지
class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String selectedCategory = '틴트';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더 영역
            const SliverToBoxAdapter(child: _RankingHeader()),

            // 헤더 아래부터 TOP20 제목까지: 화면 양옆 padding 16 적용
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // 카테고리
                    _CategorySection(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // TOP3 영역
                    _Top3Section(
                      top3: _kTop3,
                      onProductTap: (item) => _goToDetail(context, item),
                    ),

                    // TOP20 제목
                    const _Top20Title(),
                  ],
                ),
              ),
            ),

            // TOP20 리스트 영역
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: _RankingListSection(
                products: _kProducts,
                onProductTap: (item) => _goToDetail(context, item),
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

// 헤더 컴포넌트
class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const MainHeader(
        title: '내 추구미 랭킹',
        subtitle: '피드 기반으로 측정됩니다',
        padding: EdgeInsets.fromLTRB(18, 20, 18, 14),
      ),
    );
  }
}

// 카테고리 칩 컴포넌트
class _CategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategorySection({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    const categories = ['틴트', '렌즈', '볼터치', '섀도우'];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          return CategoryChip(
            text: category,
            selected: selectedCategory == category,
            onTap: () {
              onCategorySelected(category);
            },
          );
        },
      ),
    );
  }
}

// TOP3 전체 컴포넌트
class _Top3Section extends StatefulWidget {
  final List<RankingProduct> top3;
  final ValueChanged<RankingProduct> onProductTap;

  const _Top3Section({required this.top3, required this.onProductTap});

  @override
  State<_Top3Section> createState() => _Top3SectionState();
}

class _Top3SectionState extends State<_Top3Section> {
  late final PageController _pageController;
  double _currentPage = 0;
  Timer? _autoScrollTimer;

  static const int _virtualMultiplier = 10000;

  int get _initialPage => widget.top3.length * (_virtualMultiplier ~/ 2);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: _initialPage,
    );
    _currentPage = _initialPage.toDouble();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? _currentPage);
    });
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.top3.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'TOP3'),

        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: count * _virtualMultiplier,
            itemBuilder: (context, index) {
              final product = widget.top3[index % count];
              final distance = (_currentPage - index).abs();
              final scale = (1 - distance * 0.12).clamp(0.85, 1.0);

              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: () => widget.onProductTap(product),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffeeeeee),
                          image: DecorationImage(
                            image: AssetImage(product.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '# ${product.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.top3.length, (i) {
            final isActive = _currentPage.round() % widget.top3.length == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}

// TOP20 제목 컴포넌트
class _Top20Title extends StatelessWidget {
  const _Top20Title();

  @override
  Widget build(BuildContext context) {
    return const _SectionTitle(title: 'TOP20');
  }
}

// 공통 섹션 제목 컴포넌트
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

// TOP20 리스트 컴포넌트
class _RankingListSection extends StatelessWidget {
  final List<RankingProduct> products;
  final ValueChanged<RankingProduct> onProductTap;

  const _RankingListSection({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = products[index];

        return ProductItemContainer(
          rank: item.rank,
          imagePath: item.imagePath,
          brandName: item.brand,
          productName: item.name,
          price: '',
          onTap: () => onProductTap(item),
          onOpenTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withValues(alpha: 0.25),
              isScrollControlled: true,
              builder: (context) {
                return ProductMorePopup(
                  imagePath: item.imagePath,
                  brand: item.brand,
                  name: item.name,
                );
              },
            );
          },
        );
      }, childCount: products.length),
    );
  }
}
