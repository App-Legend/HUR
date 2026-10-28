import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/library/product_list_page.dart';

/// 제품 `...` 메뉴: 내 화장품 / 찜하기 / 유사한 화장품 더 보기 / 덜 보기.
/// 내 화장품·찜·덜 보기를 바꾸면 시트를 닫으면서 true를 돌려준다. (목록 화면이 새로고침할 수 있게)
class ProductMorePopup extends StatefulWidget {
  final String imagePath;
  final String brand;
  final String name;
  final int? productId;

  const ProductMorePopup({
    super.key,
    required this.imagePath,
    required this.brand,
    required this.name,
    this.productId,
  });

  @override
  State<ProductMorePopup> createState() => _ProductMorePopupState();
}

class _ProductMorePopupState extends State<ProductMorePopup> {
  String? _token;
  final Map<String, bool> _marks = {'wish': false, 'own': false, 'hide': false};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final id = widget.productId;
    if (_token == null || id == null) return;
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products/$id/marks'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          for (final kind in _marks.keys) {
            _marks[kind] = data[kind] == true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _toggle(String kind, {required String onMessage, required String offMessage}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final id = widget.productId;

    if (_token == null || id == null) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(id == null ? '이 화장품은 저장할 수 없어요.' : '로그인이 필요한 기능이에요.'),
      ));
      return;
    }

    final turnOn = !(_marks[kind] ?? false);
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/products/$id/mark'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'kind': kind, 'on': turnOn}),
      );
      if (res.statusCode == 401) {
        if (mounted) await handleUnauthorized(context);
        return;
      }
      if (res.statusCode != 200) throw Exception('mark ${res.statusCode}');
      navigator.pop(true);
      messenger.showSnackBar(SnackBar(content: Text(turnOn ? onMessage : offMessage)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('처리하지 못했어요. 잠시 후 다시 시도해주세요.')));
    }
  }

  void _showSimilar() {
    final id = widget.productId;
    final navigator = Navigator.of(context);
    navigator.pop();
    if (id == null) return;
    navigator.push(MaterialPageRoute(
      builder: (_) => ProductListPage(
        title: '${widget.name}와 비슷한 화장품',
        path: '/products/$id/similar',
        emptyText: '비슷한 화장품을 찾지 못했어요.',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.imagePath;
    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
      decoration: const BoxDecoration(
        color: HurColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -46,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 86,
                          height: 86,
                          color: HurColors.placeholder,
                          child: const Icon(Icons.image_not_supported, color: HurColors.muted),
                        ),
                      )
                    : Image.asset(imagePath, width: 86, height: 86, fit: BoxFit.cover),
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close, size: 28, color: HurColors.muted),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: HurColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.brand,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: HurColors.muted),
                ),

                const SizedBox(height: 28),

                _MoreMenuItem(
                  icon: Symbols.check_circle,
                  active: _marks['own'] ?? false,
                  text: (_marks['own'] ?? false) ? '내 화장품에서 빼기' : '내 화장품에 담기',
                  onTap: () => _toggle(
                    'own',
                    onMessage: '내 화장품에 담았어요.',
                    offMessage: '내 화장품에서 뺐어요.',
                  ),
                ),
                _MoreMenuItem(
                  icon: Symbols.star,
                  active: _marks['wish'] ?? false,
                  text: (_marks['wish'] ?? false) ? '찜 취소' : '찜하기',
                  onTap: () => _toggle(
                    'wish',
                    onMessage: '찜했어요.',
                    offMessage: '찜을 취소했어요.',
                  ),
                ),
                _MoreMenuItem(
                  icon: Symbols.heart_plus,
                  text: '유사한 화장품 더 보기',
                  onTap: _showSimilar,
                ),
                _MoreMenuItem(
                  icon: Symbols.heart_minus,
                  active: _marks['hide'] ?? false,
                  text: (_marks['hide'] ?? false) ? '다시 보기' : '유사한 화장품 덜 보기',
                  onTap: () => _toggle(
                    'hide',
                    onMessage: '이 화장품을 숨겼어요. 랭킹과 비슷한 화장품 목록에서 보이지 않아요.',
                    offMessage: '이 화장품이 다시 보이도록 했어요.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool active;

  const _MoreMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              fill: active ? 1 : 0,
              color: active ? HurColors.accent : HurColors.text,
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: active ? HurColors.accent : HurColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
