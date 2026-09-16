//  ————————————————————————————————
//  |        검색 후 화장품 탭        |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/common/widget/product_more_popup.dart';
import 'package:hur_app/ui/pages/ranking/detail_ranking_page.dart';

import 'package:hur_app/app/constants.dart';

class SearchResultCosmeticsTab extends StatefulWidget {
  final String query;

  const SearchResultCosmeticsTab({super.key, required this.query});

  @override
  State<SearchResultCosmeticsTab> createState() =>
      _SearchResultCosmeticsTabState();
}

class _SearchResultCosmeticsTabState extends State<SearchResultCosmeticsTab> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts(widget.query);
  }

  // 검색어가 바뀌면 다시 fetch
  @override
  void didUpdateWidget(SearchResultCosmeticsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchProducts(widget.query);
    }
  }

  Future<void> _fetchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/products/search'
              '?q=${Uri.encodeComponent(query)}&limit=20',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _products = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '검색 결과를 불러오지 못했습니다';
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

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      );
    }

    // 에러
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }

    // 결과 없음
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xffbdbdbd)),
            const SizedBox(height: 12),
            Text(
              "'${widget.query}' 검색 결과가 없어요",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 결과 리스트
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        final rank = (index + 1).toString();
        final imagePath = p['image'] as String? ?? '';
        final brand    = p['brand'] as String? ?? '';
        final name     = p['name']  as String? ?? '';

        return ProductItemContainer(
          rank: rank,
          imagePath: imagePath,
          brandName: brand,
          productName: name,
          price: '',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailRankingPage(
                rank: rank,
                imagePath: imagePath,
                brand: brand,
                name: name,
              ),
            ),
          ),
          onOpenTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.25),
            isScrollControlled: true,
            builder: (_) => ProductMorePopup(
              imagePath: imagePath,
              brand: brand,
              name: name,
            ),
          ),
        );
      },
    );
  }
}
