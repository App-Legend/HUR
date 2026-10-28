//  ————————————————————————————————
//  |          조회 기록             |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/home/detail/detail_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      try {
        final res = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/post/history/me'),
          headers: {'Authorization': 'Bearer $_token'},
        );
        if (!mounted) return;
        if (res.statusCode == 401) {
          await handleUnauthorized(context);
          return;
        }
        if (res.statusCode == 200) {
          setState(() => _posts = List<Map<String, dynamic>>.from(jsonDecode(res.body)['posts']));
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('조회 기록을 모두 지울까요?'),
        content: const Text('지운 기록은 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('모두 지우기', style: TextStyle(color: HurColors.peach)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/post/history/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 200 && mounted) setState(() => _posts = []);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지우지 못했어요. 인터넷 연결을 확인해주세요.')),
        );
      }
    }
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
        title: const Text(
          '조회 기록',
          style: TextStyle(color: HurColors.text, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_posts.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: const Text('모두 지우기', style: TextStyle(color: HurColors.muted, fontSize: 13)),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HurColors.accent))
          : _token == null
              ? const Center(
                  child: Text('로그인하면 볼 수 있어요.', style: TextStyle(fontSize: 15, color: HurColors.muted)),
                )
              : _posts.isEmpty
                  ? const Center(
                      child: Text('최근에 본 게시물이 없어요.', style: TextStyle(fontSize: 15, color: HurColors.muted)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, index) {
                        final post = _posts[index];
                        final imageUrl = ApiConstants.imageUrl(post['post_image']);
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailHomePage(
                                  imageUrl: imageUrl,
                                  nickname: post['nickname'] ?? '',
                                  title: post['title'] ?? '',
                                  postId: post['post_id'] as int,
                                ),
                              ),
                            );
                            if (mounted) _load();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(color: HurColors.surfaceStrong),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
