import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/notification_prefs.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/home_post_more_popup.dart';
import 'package:hur_app/ui/common/widget/side_drawer.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail/detail_home_page.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/login/login_page.dart';
import 'package:hur_app/ui/pages/notifications/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = '발견';
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 0;
  int? _userId;
  String? _token;
  int _unread = 0;
  String? _onboardingColor;
  String? _onboardingSkinTone;
  String? _onboardingMood;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300
        && !_isFetchingMore
        && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    _token = prefs.getString('auth_token');
    _onboardingColor = prefs.getString('onboarding_color');
    _onboardingSkinTone = prefs.getString('onboarding_skin_tone');
    _onboardingMood = prefs.getString('onboarding_mood');
    _loadUnread();
    await _fetchFeed(page: 0);
  }

  // 안 읽은 알림이 있을 때만 벨에 빨간 점을 보여준다.
  Future<void> _loadUnread() async {
    if (_userId == null || _token == null) return;
    final types = await enabledNotificationTypes();
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/unread-count')
            .replace(queryParameters: {'types': types}),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _unread = jsonDecode(res.body)['count'] ?? 0);
      }
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인하면 알림을 받을 수 있어요.')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    _loadUnread();
  }

  Future<void> _fetchFeed({required int page}) async {
    try {
      final Map<String, String> queryParams = {'page': page.toString()};
      if (_userId != null) {
        queryParams['user_id'] = _userId.toString();
      } else {
        if (_onboardingColor != null) queryParams['color'] = _onboardingColor!;
        if (_onboardingSkinTone != null) queryParams['skin_tone'] = _onboardingSkinTone!;
        if (_onboardingMood != null) queryParams['mood'] = _onboardingMood!;
      }
      final uri = Uri.parse('${ApiConstants.baseUrl}/post/feed').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetched = List<Map<String, dynamic>>.from(data['posts']);
        setState(() {
          if (page == 0) {
            _posts = fetched;
          } else {
            _posts = [..._posts, ...fetched];
          }
          _hasMore = fetched.length >= 20;
          _page = page;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() => _isFetchingMore = true);
    await _fetchFeed(page: _page + 1);
    if (mounted) setState(() => _isFetchingMore = false);
  }

  Future<void> _refresh() => _fetchFeed(page: 0);

  // 상세에서 게시물을 삭제하고 돌아오면(true) 피드를 다시 불러온다.
  Future<void> _openDetail(Map<String, dynamic> post, String imageUrl) async {
    final deleted = await Navigator.push<bool>(
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
    if (deleted == true && mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = <Map<String, dynamic>>[];
    final rightItems = <Map<String, dynamic>>[];
    for (int i = 0; i < _posts.length; i++) {
      if (i.isEven) {
        leftItems.add(_posts[i]);
      } else {
        rightItems.add(_posts[i]);
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: HurColors.bg,
        drawer: const SideDrawer(),
        body: Column(
          children: [
            MainHeader(
              bottom: _HomeHeader(
                selectedTab: selectedTab,
                hasUnread: _unread > 0,
                onBellTap: _openNotifications,
                onTapTab: (tab) {
                  setState(() {
                    selectedTab = tab;
                  });
                },
              ),
            ),

            Container(
              height: 1,
              color: const Color.fromARGB(255, 206, 206, 206),
            ),

            Expanded(
              child: selectedTab == '발견'
                  ? _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: HurColors.accent,
                            ),
                          )
                        : _posts.isEmpty
                        ? RefreshIndicator(
                            color: HurColors.accent,
                            backgroundColor: HurColors.panel,
                            onRefresh: _refresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 240),
                                Center(
                                  child: Text(
                                    '게시물이 없습니다.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HurColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            child: RefreshIndicator(
                              color: HurColors.accent,
                              backgroundColor: HurColors.panel,
                              onRefresh: _refresh,
                              child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: leftItems.map((post) {
                                            final imageUrl =
                                                ApiConstants.imageUrl(post['post_image']);
                                            return GestureDetector(
                                              onTap: () => _openDetail(post, imageUrl),
                                              child: _ImageCard(
                                                imageUrl: imageUrl,
                                                label: post['nickname'],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Column(
                                          children: rightItems.map((post) {
                                            final imageUrl =
                                                ApiConstants.imageUrl(post['post_image']);
                                            return GestureDetector(
                                              onTap: () => _openDetail(post, imageUrl),
                                              child: _ImageCard(
                                                imageUrl: imageUrl,
                                                label: post['nickname'],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isFetchingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: CircularProgressIndicator(color: HurColors.accent),
                                    ),
                                ],
                              ),
                            ),
                            ),
                          )
                  : _FollowingFeed(userId: _userId, token: _token),
            ),
          ],
        ),
      ),
    );
  }
}

// 팔로우 탭: 내가 팔로우한 사람들의 게시물을 최신순으로 보여준다.
class _FollowingFeed extends StatefulWidget {
  final int? userId;
  final String? token;

  const _FollowingFeed({required this.userId, required this.token});

  @override
  State<_FollowingFeed> createState() => _FollowingFeedState();
}

class _FollowingFeedState extends State<_FollowingFeed> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.userId != null) {
      _fetch(page: 0);
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isFetchingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _fetch({required int page}) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/post/feed/following?page=$page'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (!mounted) return;
      if (res.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
      if (res.statusCode == 200) {
        final fetched = List<Map<String, dynamic>>.from(jsonDecode(res.body)['posts']);
        setState(() {
          _posts = page == 0 ? fetched : [..._posts, ...fetched];
          _hasMore = fetched.length >= 20;
          _page = page;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() => _isFetchingMore = true);
    await _fetch(page: _page + 1);
    if (mounted) setState(() => _isFetchingMore = false);
  }

  Future<void> _refresh() => _fetch(page: 0);

  Future<void> _openDetail(Map<String, dynamic> post, String imageUrl) async {
    final deleted = await Navigator.push<bool>(
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
    if (deleted == true && mounted) await _refresh();
  }

  Widget _column(List<Map<String, dynamic>> items) {
    return Expanded(
      child: Column(
        children: items.map((post) {
          final imageUrl = ApiConstants.imageUrl(post['post_image']);
          return GestureDetector(
            onTap: () => _openDetail(post, imageUrl),
            child: _ImageCard(imageUrl: imageUrl, label: post['nickname']),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '로그인하면 팔로우한 사람의 게시물을 볼 수 있어요.',
              style: TextStyle(fontSize: 15, color: HurColors.muted),
            ),
            const SizedBox(height: 12),
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
        ),
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: HurColors.accent));
    }
    if (_posts.isEmpty) {
      return RefreshIndicator(
        color: HurColors.accent,
        backgroundColor: HurColors.panel,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 240),
            Center(
              child: Text(
                '팔로우한 사람의 게시물이 아직 없어요.\n마음에 드는 계정을 팔로우해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: HurColors.muted, height: 1.6),
              ),
            ),
          ],
        ),
      );
    }

    final left = <Map<String, dynamic>>[];
    final right = <Map<String, dynamic>>[];
    for (int i = 0; i < _posts.length; i++) {
      (i.isEven ? left : right).add(_posts[i]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: RefreshIndicator(
        color: HurColors.accent,
        backgroundColor: HurColors.panel,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _column(left),
                  const SizedBox(width: 8),
                  _column(right),
                ],
              ),
              if (_isFetchingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: HurColors.accent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTapTab;
  final bool hasUnread;
  final VoidCallback onBellTap;

  const _HomeHeader({
    required this.selectedTab,
    required this.onTapTab,
    required this.hasUnread,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Symbols.menu,
                size: 25,
                color: HurColors.text,
                weight: 400,
              ),
            ),
          ),

          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HeaderTab(
                  text: '발견',
                  selected: selectedTab == '발견',
                  onTap: () => onTapTab('발견'),
                ),
                const SizedBox(width: 20),
                _HeaderTab(
                  text: '팔로우',
                  selected: selectedTab == '팔로우',
                  onTap: () => onTapTab('팔로우'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  onPressed: onBellTap,
                  icon: const Icon(
                    Symbols.notifications_none,
                    size: 28,
                    color: HurColors.text,
                    weight: 400,
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: HurColors.accent,
                        shape: BoxShape.circle,
                      ),
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

class _HeaderTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? HurColors.accent : HurColors.text,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: 42,
              height: 2,
              color: selected ? HurColors.accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imageUrl;
  final String? label;

  const _ImageCard({required this.imageUrl, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(color: HurColors.surfaceStrong),
                );
              },
              errorBuilder: (context, error, stackTrace) => AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(color: HurColors.surfaceStrong),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: label != null
                      ? Text(
                          label!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: HurColors.text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showPostMoreOptions(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: HurColors.muted,
                    ),
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
