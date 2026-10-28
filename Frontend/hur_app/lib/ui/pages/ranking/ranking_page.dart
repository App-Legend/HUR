import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/common/widget/product_more_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_ranking_page.dart';

import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';

// 상품 데이터가 준비된 카테고리. 나머지는 '준비중'으로 보여준다.
const _readyCategories = {'틴트', '피부', '볼터치', '섀도우'};

// ─────────────────────────────────────────────
// 랭킹 상품 데이터 모델
// ─────────────────────────────────────────────
class RankingProduct {
  final int? id;
  final String rank;
  final String imagePath; // asset 경로 or https:// URL
  final String brand;
  final String name;

  const RankingProduct({
    this.id,
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
  });

  factory RankingProduct.fromJson(Map<String, dynamic> json, int rankNum) {
    return RankingProduct(
      id: json['id'] as int?,
      rank: rankNum.toString(),
      imagePath: json['image'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

// imagePath가 http로 시작하면 NetworkImage, 아니면 AssetImage
ImageProvider _imageProvider(String path) {
  if (path.startsWith('http')) return NetworkImage(path);
  return AssetImage(path);
}

// ─────────────────────────────────────────────
// 전체 랭킹 페이지
// ─────────────────────────────────────────────
class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String _selectedCategory = '틴트';
  List<RankingProduct> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRanking('틴트');
  }

  Future<void> _fetchRanking(String category) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final queryParams = {
        'category': category,
        'limit': '20',
      };
      // 로그인했으면 토큰을 같이 보내서 '내 추구미' 기준 랭킹을 받는다.
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/products/ranking')
                .replace(queryParameters: queryParams),
            headers: {
              if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _products = data.asMap().entries.map((e) {
            return RankingProduct.fromJson(
              e.value as Map<String, dynamic>,
              e.key + 1,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '데이터를 불러오지 못했습니다 (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '서버에 연결할 수 없습니다';
        _isLoading = false;
      });
    }
  }

  List<RankingProduct> get _top3 => _products.take(3).toList();
  List<RankingProduct> get _listProducts => _products.skip(3).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 헤더
            const SliverToBoxAdapter(child: _RankingHeader()),

            // ── 카테고리 + TOP3 + TOP20 제목
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    _CategorySection(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() => _selectedCategory = category);
                        if (_readyCategories.contains(category)) _fetchRanking(category);
                      },
                    ),

                    const SizedBox(height: 15),

                    // 틴트 외 카테고리 → 준비중
                    if (!_readyCategories.contains(_selectedCategory))
                      const _ComingSoonSection()
                    // 로딩 중
                    else if (_isLoading)
                      const SizedBox(
                        height: 280,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: HurColors.text,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    // 에러
                    else if (_error != null)
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(
                                    color: HurColors.muted, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _fetchRanking(_selectedCategory),
                                child: const Text(
                                  '다시 시도',
                                  style: TextStyle(
                                    color: HurColors.text,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // TOP3
                    else if (_top3.isNotEmpty)
                      _Top3Section(
                        top3: _top3,
                        onProductTap: (item) => _goToDetail(context, item),
                      ),

                    if (_readyCategories.contains(_selectedCategory) && !_isLoading && _error == null)
                      const _Top20Title(),
                  ],
                ),
              ),
            ),

            // ── TOP20 리스트
            if (_readyCategories.contains(_selectedCategory) && !_isLoading && _error == null && _listProducts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: _RankingListSection(
                  products: _listProducts,
                  onProductTap: (item) => _goToDetail(context, item),
                  // '덜 보기' 등으로 내 목록이 바뀌면 랭킹을 다시 불러온다.
                  onProductChanged: () => _fetchRanking(_selectedCategory),
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
          productId: item.id,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 헤더 컴포넌트
// ─────────────────────────────────────────────
class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HurColors.bg,
      child: const MainHeader(
        title: '내 추구미 랭킹',
        titleFontSize: 19,
        subtitle: '피드 기반으로 측정됩니다',
        subtitleFontSize: 12,
        padding: EdgeInsets.fromLTRB(18, 20, 18, 6),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 카테고리 칩
// ─────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategorySection({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    const categories = ['틴트', '피부', '볼터치', '섀도우', '렌즈'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final category = categories[index];
          return CategoryChip(
            text: category,
            selected: selectedCategory == category,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP3 캐러셀
// ─────────────────────────────────────────────
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
            itemBuilder: (_, index) {
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
                          color: HurColors.surfaceStrong,
                          image: DecorationImage(
                            image: _imageProvider(product.imagePath),
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
                              color: HurColors.text,
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
            final isActive =
                _currentPage.round() % widget.top3.length == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? HurColors.text : HurColors.border,
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

// ─────────────────────────────────────────────
// TOP20 제목
// ─────────────────────────────────────────────
class _Top20Title extends StatelessWidget {
  const _Top20Title();

  @override
  Widget build(BuildContext context) => const _SectionTitle(title: 'TOP20');
}

// 공통 섹션 제목
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
          color: HurColors.text,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP20 리스트
// ─────────────────────────────────────────────
class _RankingListSection extends StatelessWidget {
  final List<RankingProduct> products;
  final ValueChanged<RankingProduct> onProductTap;
  final VoidCallback? onProductChanged;

  const _RankingListSection({
    required this.products,
    required this.onProductTap,
    this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = products[index];
          return ProductItemContainer(
            rank: item.rank,
            imagePath: item.imagePath,
            brandName: item.brand,
            productName: item.name,
            price: '',
            onTap: () => onProductTap(item),
            onOpenTap: () async {
              final changed = await showModalBottomSheet<bool>(
                context: context,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withValues(alpha: 0.25),
                isScrollControlled: true,
                builder: (_) => ProductMorePopup(
                  imagePath: item.imagePath,
                  brand: item.brand,
                  name: item.name,
                  productId: item.id,
                ),
              );
              if (changed == true) onProductChanged?.call();
            },
          );
        },
        childCount: products.length,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 준비중 화면
// ─────────────────────────────────────────────
class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: HurColors.surfaceStrong,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                size: 40,
                color: HurColors.muted,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '준비 중이에요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HurColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '곧 만나볼 수 있어요 :)',
              style: TextStyle(
                fontSize: 13,
                color: HurColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
