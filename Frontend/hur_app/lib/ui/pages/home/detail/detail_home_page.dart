//  ————————————————————————————————
//  |         피드 상세 페이지        |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/pages/home/detail/popup/comment_popup.dart';
import 'package:hur_app/ui/pages/home/detail/popup/purchase_popup.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/detail_icon_action_bar.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/detail_profile_header.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/image_tag_section.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/used_product_header.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/used_product_list.dart';
import 'package:hur_app/ui/pages/login/login_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/app/theme.dart';

class DetailHomePage extends StatefulWidget {
  final String imageUrl;
  final String nickname;
  final String title;
  final int postId;

  const DetailHomePage({
    super.key,
    required this.imageUrl,
    required this.nickname,
    required this.title,
    required this.postId,
  });

  @override
  State<DetailHomePage> createState() => _DetailHomePage();
}

class _DetailHomePage extends State<DetailHomePage> {
  bool isLiked = false;
  bool isBookmark = false;
  int bookmarkCount = 0;
  int likeCount = 0;
  int _commentCount = 0;
  int? _userId;
  String? _token;

  Map<String, dynamic>? _post;
  bool _postLoading = true;
  bool _isRestricted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    _token = prefs.getString('auth_token');
    await Future.wait([_loadPostDetail(), _loadLikeStatus(), _loadBookmarkStatus(), _recordView()]);
  }

  bool get _isMyPost => _userId != null && _post?['user_id'] == _userId;

  // 웹 주소가 없어서 게시물 소개 문구를 공유한다.
  Future<void> _sharePost() async {
    final nickname = widget.nickname.isNotEmpty ? widget.nickname : (_post?['nickname'] ?? '');
    final title = widget.title.isNotEmpty ? widget.title : (_post?['title'] ?? '');
    await SharePlus.instance.share(
      ShareParams(text: 'HUR에서 $nickname님의 게시물 "$title"을(를) 확인해보세요!'),
    );
  }

  Future<void> _loadBookmarkStatus() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/bookmark'),
        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          isBookmark = data['bookmarked'] ?? false;
          bookmarkCount = data['count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  void _toggleBookmark() async {
    if (_userId == null) {
      _showLoginRequired();
      return;
    }
    setState(() {
      isBookmark = !isBookmark;
      bookmarkCount += isBookmark ? 1 : -1;
    });
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/bookmark'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 401) {
        if (mounted) await handleUnauthorized(context);
        return;
      }
      if (res.statusCode != 200) throw Exception('bookmark ${res.statusCode}');
    } catch (_) {
      if (mounted) {
        setState(() {
          isBookmark = !isBookmark;
          bookmarkCount += isBookmark ? 1 : -1;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HurColors.bg,
        title: const Text('게시물을 삭제할까요?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: HurColors.text)),
        content: const Text('삭제하면 되돌릴 수 없어요.', style: TextStyle(color: HurColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: HurColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: HurColors.peach, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) await _deletePost();
  }

  Future<void> _deletePost() async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pop(context, true);
        return;
      }
      if (res.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했어요. 잠시 후 다시 시도해주세요.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제하지 못했어요. 인터넷 연결을 확인해주세요.')),
        );
      }
    }
  }

  Future<void> _loadPostDetail() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}')
          .replace(queryParameters: _userId != null ? {'viewer_id': _userId.toString()} : null);
      final res = await http.get(uri);
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _post = data;
          _commentCount = data['comment_count'] ?? 0;
        });
      } else if (res.statusCode == 403 && mounted) {
        setState(() => _isRestricted = true);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _postLoading = false);
    }
  }

  Future<void> _loadLikeStatus() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/like')
          .replace(queryParameters: _userId != null ? {'user_id': _userId.toString()} : null);
      final res = await http.get(uri);
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          isLiked = data['liked'] ?? false;
          likeCount = data['count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _recordView() async {
    if (_userId == null) return;
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/score'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'action': 'view'}),
      );
    } catch (_) {}
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요해요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: HurColors.text)),
        content: const Text('이 기능은 로그인 후 이용할 수 있어요.', style: TextStyle(color: HurColors.muted)),
        backgroundColor: HurColors.bg,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: HurColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            child: const Text('로그인', style: TextStyle(color: HurColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _toggleLike() async {
    if (_userId == null) {
      _showLoginRequired();
      return;
    }
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
      }
    }
  }

  void _showCommentPopup() {
    if (_userId == null) {
      _showLoginRequired();
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      builder: (context) => CommentPopup(
        postId: widget.postId,
        userId: _userId,
        onCommentAdded: () {
          if (mounted) setState(() => _commentCount++);
        },
      ),
    );
  }

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
    // 퍼스널컬러 AI 분류는 정확도가 낮아(약 30%) 화면에는 보여주지 않는다. DB에는 그대로 저장된다.
    final categories = ((_post?['categories'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [])
        .where((cat) => cat['category_type'] != 'personal_color')
        .toList();
    final stickers = (_post?['stickers'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Scaffold(
      backgroundColor: HurColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            MainHeader(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: HurColors.text),
                onPressed: () => Navigator.pop(context),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isMyPost)
                    IconButton(
                      tooltip: '게시물 삭제',
                      icon: const Icon(Icons.delete_outline, color: HurColors.muted),
                      onPressed: _confirmDelete,
                    ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: HurColors.muted),
                    onPressed: _sharePost,
                  ),
                ],
              ),
              showDivider: false,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            Expanded(
              child: _isRestricted
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 64, color: HurColors.border),
                          const SizedBox(height: 16),
                          const Text(
                            '팔로우한 사람만 볼 수 있는 게시물이에요.',
                            style: TextStyle(color: HurColors.muted, fontSize: 15),
                          ),
                          if (_userId == null) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              ),
                              child: const Text(
                                '로그인하기',
                                style: TextStyle(color: HurColors.accent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    DetailProfileHeader(
                        nickname: widget.nickname,
                        userId: _post?['user_id'] as int?,
                        onFollowTap: () {}),
                    const SizedBox(height: 12),
                    ImageTagSection(
                      imageUrl: widget.imageUrl,
                      stickers: stickers,
                    ),
                    DetailIconActionBar(
                      isLiked: isLiked,
                      isBookmark: isBookmark,
                      likeCount: likeCount,
                      commentCount: _commentCount,
                      bookmarkCount: bookmarkCount,
                      onLikeTap: _toggleLike,
                      onCommentTap: _showCommentPopup,
                      onBookmarkTap: _toggleBookmark,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: HurColors.text,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_postLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else ...[
                            if ((_post?['post_content'] as String?)?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Text(
                                _post!['post_content'],
                                style: const TextStyle(
                                    color: HurColors.text, fontSize: 14, height: 1.4),
                              ),
                            ],
                            if (categories.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories.map((cat) {
                                  return CategoryChip(
                                    text: '#${cat['category_value']}',
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    fontSize: 12,
                                    borderRadius: 20,
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 14),
                            UsedProductHeader(count: stickers.length),
                            const SizedBox(height: 14),
                            UsedProductList(
                              onOpenTap: _showPurchasePopup,
                              stickers: stickers,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

