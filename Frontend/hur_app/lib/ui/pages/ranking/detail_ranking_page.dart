//  ————————————————————————————————
//  |        상품 상세 페이지         |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/pages/home/detail/detail_home_page.dart';
import 'package:hur_app/ui/pages/home/detail/popup/purchase_popup.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const _kDetailCategories = ['전체', '봄 웜', '가을 웜', '여름 쿨', '겨울 쿨'];

class DetailRankingPage extends StatefulWidget {
  final String rank;
  final String imagePath;
  final String brand;
  final String name;
  final int? productId;

  const DetailRankingPage({
    super.key,
    required this.rank,
    required this.imagePath,
    required this.brand,
    required this.name,
    this.productId,
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: true,
      builder: (context) => const PurchasePopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => selectedTab = '사진'),
                    child: _TabText(text: '사진', selected: selectedTab == '사진'),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => selectedTab = '후기'),
                    child: _TabText(text: '후기', selected: selectedTab == '후기'),
                  ),
                ),
              ],
            ),

            Container(height: 1, color: const Color(0xffeeeeee)),

            const SizedBox(height: 12),

            if (selectedTab == '사진')
              Expanded(
                child: _PhotoTab(
                  imagePath: widget.imagePath,
                  rank: widget.rank,
                  productId: widget.productId,
                  selectedCategory: selectedCategory,
                  onCategorySelected: (cat) =>
                      setState(() => selectedCategory = cat),
                  onPurchaseTap: _showPurchasePopup,
                ),
              )
            else
              const Expanded(child: _ReviewTab()),
          ],
        ),
      ),
    );
  }
}

class _PhotoTab extends StatefulWidget {
  final String imagePath;
  final String rank;
  final int? productId;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onPurchaseTap;

  const _PhotoTab({
    required this.imagePath,
    required this.rank,
    required this.productId,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onPurchaseTap,
  });

  @override
  State<_PhotoTab> createState() => _PhotoTabState();
}

class _PhotoTabState extends State<_PhotoTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (widget.productId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/post/by-product/${widget.productId}'),
      );
      if (res.statusCode == 200 && mounted) {
        final List data = jsonDecode(res.body);
        setState(() {
          _posts = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _kDetailCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _kDetailCategories[index];
              return CategoryChip(
                text: cat,
                selected: widget.selectedCategory == cat,
                onTap: () => widget.onCategorySelected(cat),
              );
            },
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(
                          widget.imagePath,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 84,
                            height: 84,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        )
                      : Image.asset(widget.imagePath, width: 84, height: 84, fit: BoxFit.cover),
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
                      children: [
                        const Text(
                          '오늘 조회 3206',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          '총 ${_posts.length}회 사용',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(width: 30),

                    GestureDetector(
                      onTap: widget.onPurchaseTap,
                      child: const Icon(
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                  ? const Center(
                      child: Text(
                        '이 제품이 태그된 게시물이 없어요',
                        style: TextStyle(color: Colors.black38, fontSize: 14),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                      itemCount: _posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 6,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        final imageUrl = '${ApiConstants.baseUrl}${post['post_image'] ?? ''}';
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailHomePage(
                                imageUrl: imageUrl,
                                nickname: post['nickname'] ?? '',
                                title: post['title'] ?? '',
                                postId: post['post_id'] as int,
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: const [
        _ReviewItem(userName: 'user_01', review: '색감이 예쁘고 데일리로 쓰기 좋아요.'),
        _ReviewItem(userName: 'user_02', review: '발림성이 부드럽고 광택감이 마음에 들어요.'),
        _ReviewItem(userName: 'user_03', review: '생각보다 지속력도 괜찮았습니다.'),
      ],
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
