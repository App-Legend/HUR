import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/pages/ranking/widgets/ranking_more_popup.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
    final top3Data = [
      ['1', 'assets/images/ranking/rank1.png', '랭킹 1위 브랜드', '랭킹 1위 제품'],
      ['2', 'assets/images/ranking/rank2.png', '랭킹 2위 브랜드', '랭킹 2위 제품'],
      ['3', 'assets/images/ranking/rank3.png', '랭킹 3위 브랜드', '랭킹 3위 제품'],
    ];

    final productsData = [
      ['4', 'assets/images/ranking/ranking4.jpg', '얼터너티브스테레오', '립 포션 카라멜 글레이즈'],
      ['5', 'assets/images/ranking/ranking5.jpg', '퓌', '로즈 옵세션 스테이핏 틴트'],
      ['6', 'assets/images/ranking/ranking6.jpg', '헤라', '센슈얼 누드 글로스'],
      ['7', 'assets/images/ranking/ranking7.jpg', '롬앤', '글래스팅 컬러 글로스'],
    ];

    final top3 = top3Data.map((e) => RankingProduct.fromList(e)).toList();
    final products = productsData
        .map((e) => RankingProduct.fromList(e))
        .toList();

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
                      top3: top3,
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
                products: products,
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
    return Column(
      children: [
        const MainHeader(
          title: '내 추구미 랭킹',
          subtitle: '피드 기반으로 측정됩니다',
          padding: EdgeInsets.fromLTRB(18, 20, 18, 7),
        ),

        const SizedBox(height: 5),

        Container(height: 1, color: const Color.fromARGB(255, 206, 206, 206)),
      ],
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
    final categories = ['틴트', '렌즈', '볼터치', '섀도우'];

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
class _Top3Section extends StatelessWidget {
  final List<RankingProduct> top3;
  final ValueChanged<RankingProduct> onProductTap;

  const _Top3Section({required this.top3, required this.onProductTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'TOP3'),

        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 55,
                child: GestureDetector(
                  onTap: () => onProductTap(top3[1]),
                  child: _TopImage(
                    imagePath: top3[1].imagePath,
                    width: 150,
                    height: 170,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 55,
                child: GestureDetector(
                  onTap: () => onProductTap(top3[2]),
                  child: _TopImage(
                    imagePath: top3[2].imagePath,
                    width: 150,
                    height: 170,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: () => onProductTap(top3[0]),
                  child: _TopImage(
                    imagePath: top3[0].imagePath,
                    width: 255,
                    height: 210,
                  ),
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

// TOP3 이미지 컴포넌트
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
              barrierColor: Colors.black.withOpacity(0.25),
              isScrollControlled: true,
              builder: (context) {
                return RankingMorePopup(
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

// TOP20 개별 아이템 컴포넌트
// TOP20 개별 아이템 컴포넌트
class _RankingItem extends StatefulWidget {
  final String rank;
  final String imagePath;
  final String brand;
  final String name;
  final VoidCallback onTap;

  const _RankingItem({
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
    required this.onTap,
  });

  @override
  State<_RankingItem> createState() => _RankingItemState();
}

class _RankingItemState extends State<_RankingItem> {
  bool isMoreSelected = false;

  void _showMorePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      isScrollControlled: true,
      builder: (context) {
        return RankingMorePopup(
          imagePath: widget.imagePath,
          brand: widget.brand,
          name: widget.name,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
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

        //Top20 제품 리스트
        child: Row(
          children: [
            Text(
              widget.rank,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                widget.imagePath,
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
                    widget.brand,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _showMorePopup();
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(
                    Symbols.more_horiz,
                    size: 24,
                    color: Colors.black,
                    weight: 400,
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
