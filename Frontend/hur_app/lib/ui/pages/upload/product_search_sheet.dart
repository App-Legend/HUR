import 'package:flutter/material.dart';

class ProductItem {
  final String id;
  final String brand;
  final String name;
  final String? imagePath;

  const ProductItem({
    required this.id,
    required this.brand,
    required this.name,
    this.imagePath,
  });
}

const List<ProductItem> _lipProducts = [
  ProductItem(
    id: '1',
    brand: '롬앤',
    name: '베터 댄 팔레트 03',
  ),
  ProductItem(
    id: '2',
    brand: '얼터너티브스테레오',
    name: '립 포션 카라멜 글레이즈',
    imagePath: 'assets/images/ranking/rank1.png',
  ),
  ProductItem(
    id: '3',
    brand: '퓌',
    name: '로즈 옵세션 스테이핏 틴트',
    imagePath: 'assets/images/ranking/ranking5.jpg',
  ),
  ProductItem(
    id: '4',
    brand: '헤라',
    name: '센슈얼 누드 글로스',
    imagePath: 'assets/images/ranking/ranking7.jpg',
  ),
  ProductItem(id: '5', brand: '3CE', name: '무드 레시피 립 컬러'),
  ProductItem(id: '6', brand: '클리오', name: '버진 키스 블루밍 틴트'),
  ProductItem(id: '7', brand: '조선미녀', name: '비타-B 립 에센스 틴트'),
  ProductItem(id: '8', brand: '마몽드', name: '립 착 틴트'),
  ProductItem(id: '9', brand: '에뛰드', name: '픽싱 틴트'),
  ProductItem(id: '10', brand: '맥', name: '파우더 키스 리퀴드 립컬러'),
];

class ProductSearchSheet extends StatefulWidget {
  const ProductSearchSheet({super.key});

  @override
  State<ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<ProductSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<ProductItem> get _filtered {
    if (_query.isEmpty) return _lipProducts;
    return _lipProducts.where((p) {
      return p.brand.contains(_query) || p.name.contains(_query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xffdddddd),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '립 제품 검색',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '브랜드명 또는 제품명 검색',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xffaaaaaa),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xffaaaaaa),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xfff5f5f5),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      '검색 결과가 없어요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffaaaaaa),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xfff0f0f0)),
                    itemBuilder: (context, index) {
                      final product = _filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 0,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: product.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    product.imagePath!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.face_retouching_natural,
                                  color: Color(0xffcccccc),
                                  size: 24,
                                ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          product.brand,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff888888),
                          ),
                        ),
                        trailing: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xff9c27b0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
