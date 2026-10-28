//  ————————————————————————————————
//  |            알림 목록            |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/home/detail/detail_home_page.dart';
import 'package:hur_app/ui/pages/profile/feed/user_feed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _items = [];
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
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (!mounted) return;
      if (res.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _items = List<Map<String, dynamic>>.from(data['notifications']));
        // 목록을 연 순간 전부 읽은 것으로 처리한다.
        http.post(
          Uri.parse('${ApiConstants.baseUrl}/notifications/read-all'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  String _message(Map<String, dynamic> n) {
    switch (n['type']) {
      case 'like':
        return '님이 회원님의 게시물을 좋아해요.';
      case 'comment':
        return '님이 회원님의 게시물에 댓글을 남겼어요.';
      case 'follow':
        return '님이 회원님을 팔로우하기 시작했어요.';
      default:
        return '새 알림이 있어요.';
    }
  }

  String _timeAgo(String? iso) {
    final t = DateTime.tryParse(iso ?? '')?.toLocal();
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${t.month}월 ${t.day}일';
  }

  void _open(Map<String, dynamic> n) {
    if (n['type'] == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserFeedPage(userId: n['actor_id'] as int)),
      );
      return;
    }
    if (n['post_id'] == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailHomePage(
          imageUrl: ApiConstants.imageUrl(n['post_image']),
          nickname: n['owner_nickname'] ?? '',
          title: n['title'] ?? '',
          postId: n['post_id'] as int,
        ),
      ),
    );
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
          '알림',
          style: TextStyle(color: HurColors.text, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HurColors.accent))
          : RefreshIndicator(
              color: HurColors.accent,
              backgroundColor: HurColors.panel,
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 240),
                        Center(
                          child: Text(
                            '아직 알림이 없어요.',
                            style: TextStyle(fontSize: 15, color: HurColors.muted),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, thickness: 1, color: HurColors.line),
                      itemBuilder: (_, i) {
                        final n = _items[i];
                        final isFollow = n['type'] == 'follow';
                        return ListTile(
                          onTap: () => _open(n),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: HurColors.surfaceStrong,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              n['type'] == 'like'
                                  ? Icons.favorite
                                  : n['type'] == 'comment'
                                      ? Icons.mode_comment
                                      : Icons.person_add_alt_1,
                              size: 20,
                              color: HurColors.peach,
                            ),
                          ),
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: n['actor_nickname'] ?? '',
                                  style: const TextStyle(
                                    color: HurColors.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: _message(n),
                                  style: const TextStyle(color: HurColors.text),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _timeAgo(n['created_at'] as String?),
                              style: const TextStyle(color: HurColors.muted, fontSize: 12),
                            ),
                          ),
                          trailing: isFollow || n['post_image'] == null
                              ? null
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    ApiConstants.imageUrl(n['post_image']),
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        Container(width: 44, height: 44, color: HurColors.surfaceStrong),
                                  ),
                                ),
                        );
                      },
                    ),
            ),
    );
  }
}
