//  ————————————————————————————————
//  |   화장품 목록 (내 화장품/찜/유사)  |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/common/widget/product_more_popup.dart';
import 'package:hur_app/ui/pages/ranking/detail_ranking_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 서버에서 제품 배열을 받아와 목록으로 보여주는 화면. [path]는 '/products/...' 같은 API 주소.
/// [requiresLogin]이면 로그인하지 않았을 때 안내 문구를 보여준다.
class ProductListPage extends StatefulWidget {
  final String title;
  final String path;
  final String emptyText;
  final bool requiresLogin;

  const ProductListPage({
    super.key,
    required this.title,
    required this.path,
    required this.emptyText,
    this.requiresLogin = false,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _needsLogin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (widget.requiresLogin && token == null) {
      if (mounted) {
        setState(() {
          _needsLogin = true;
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${widget.path}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (!mounted) return;
      if (res.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
      if (res.statusCode == 200) {
        setState(() => _products = List<Map<String, dynamic>>.from(jsonDecode(res.body)));
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: AppBar(
        backgroundColor: HurColors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: HurColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: HurColors.text, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HurColors.accent))
          : _needsLogin
              ? const Center(
                  child: Text('로그인하면 볼 수 있어요.', style: TextStyle(fontSize: 15, color: HurColors.muted)),
                )
              : _products.isEmpty
                  ? Center(
                      child: Text(widget.emptyText, style: const TextStyle(fontSize: 15, color: HurColors.muted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        final imagePath = p['image'] as String? ?? '';
                        final brand = p['brand'] as String? ?? '';
                        final name = p['name'] as String? ?? '';
                        final id = p['id'] as int?;
                        return ProductItemContainer(
                          rank: (index + 1).toString(),
                          imagePath: imagePath,
                          brandName: brand,
                          productName: name,
                          price: '',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailRankingPage(
                                rank: (index + 1).toString(),
                                imagePath: imagePath,
                                brand: brand,
                                name: name,
                                productId: id,
                              ),
                            ),
                          ),
                          onOpenTap: () async {
                            final changed = await showModalBottomSheet<bool>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withValues(alpha: 0.25),
                              isScrollControlled: true,
                              builder: (_) => ProductMorePopup(
                                imagePath: imagePath,
                                brand: brand,
                                name: name,
                                productId: id,
                              ),
                            );
                            // 찜/내 화장품을 풀었거나 숨겼다면 목록에서도 바로 반영한다.
                            if (changed == true && mounted) _load();
                          },
                        );
                      },
                    ),
    );
  }
}
