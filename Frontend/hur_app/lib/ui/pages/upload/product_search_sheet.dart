import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';

class ProductItem {
  final int id;
  final String brand;
  final String name;
  final String? imagePath;

  const ProductItem({
    required this.id,
    required this.brand,
    required this.name,
    this.imagePath,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        id: json['id'] as int,
        brand: json['brand'] ?? '',
        name: json['name'] ?? '',
        imagePath: json['image'] as String?,
      );
}

class ProductSearchSheet extends StatefulWidget {
  const ProductSearchSheet({super.key});

  @override
  State<ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<ProductSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductItem> _products = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitial() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products/ranking?limit=30'),
      );
      if (res.statusCode == 200 && mounted) {
        final List data = jsonDecode(res.body);
        setState(() => _products = data.map((e) => ProductItem.fromJson(e)).toList());
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      _query = query;
      _isLoading = true;
    });

    if (query.trim().isEmpty) {
      await _fetchInitial();
      return;
    }

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/products/search')
          .replace(queryParameters: {'q': query.trim(), 'limit': '30'});
      final res = await http.get(uri);
      if (res.statusCode == 200 && mounted) {
        final List data = jsonDecode(res.body);
        setState(() => _products = data.map((e) => ProductItem.fromJson(e)).toList());
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            '제품 검색',
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
              onChanged: _search,
              decoration: InputDecoration(
                hintText: '브랜드명 또는 제품명 검색',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xffaaaaaa)),
                prefixIcon: const Icon(Icons.search, color: Color(0xffaaaaaa), size: 20),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty ? '제품을 불러오는 중...' : '검색 결과가 없어요',
                          style: const TextStyle(fontSize: 14, color: Color(0xffaaaaaa)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xfff0f0f0)),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final imageUrl = product.imagePath;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 0),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xfff5f5f5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.face_retouching_natural,
                                          color: Color(0xffcccccc),
                                          size: 24,
                                        ),
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
                                  color: Colors.black),
                            ),
                            subtitle: Text(
                              product.brand,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xff888888)),
                            ),
                            trailing: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xff9c27b0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
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
