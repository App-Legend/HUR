//  ————————————————————————————————
//  |      로그인 후 마이페이지       |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/widget/side_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit/profile_edit_page.dart';
import 'follow_list_page.dart';
import 'settings/settings_page.dart';
import '../home/detail/detail_home_page.dart';
import '../../../app/auth_utils.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _selectedTab = 0;
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  int _postCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _user = jsonDecode(response.body);
        });
      } else if (response.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(user: _user, isLoading: _isLoading, onRefresh: _fetchUser, postCount: _postCount),
            _TabBar(
              selected: _selectedTab,
              onTap: (i) => setState(() => _selectedTab = i),
            ),
            Expanded(child: _tabBody(_selectedTab)),
          ],
        ),
      ),
    );
  }

  Widget _tabBody(int index) {
    switch (index) {
      case 1:
        return const _EmptyTab(icon: Icons.location_on_outlined);
      case 2:
        return const _EmptyTab(icon: Icons.bookmark_border);
      default:
        return _PostsGrid(onPostsLoaded: (count) => setState(() => _postCount = count));
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final VoidCallback onRefresh;
  final int postCount;

  const _ProfileHeader({required this.user, required this.isLoading, required this.onRefresh, required this.postCount});

  void _goToFollowList(BuildContext context, bool isFollowers) {
    final userId = user?['id'];
    if (userId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowListPage(userId: userId, isFollowers: isFollowers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nickname = user?['nickname'] ?? '닉네임 없음';
    final bio = user?['bio'];
    final profileImage = user?['profile_image'] as String?;
    final backgroundImage = user?['background_image'] as String?;
    final followerCount  = user?['follower_count']  ?? 0;
    final followingCount = user?['following_count'] ?? 0;
    final aestheticTag = user?['aesthetic_tag'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB0B0B0),
        image: backgroundImage != null
            ? DecorationImage(image: NetworkImage(backgroundImage), fit: BoxFit.cover)
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                  );
                  onRefresh();
                },
                icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                label: const Text('프로필 편집', style: TextStyle(color: Colors.white, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  shape: BoxShape.circle,
                  image: profileImage != null
                      ? DecorationImage(image: NetworkImage(profileImage), fit: BoxFit.cover)
                      : null,
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : null,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$postCount',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' 게시물',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _goToFollowList(context, true),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$followerCount',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: ' 팔로워',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _goToFollowList(context, false),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$followingCount',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: ' 팔로잉',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            bio ?? '자기소개가 없습니다',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            children: [
              if (aestheticTag != null)
                _TagChip(label: aestheticTag, icon: Icons.auto_awesome_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TagChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _TabBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.grid_on,
      Icons.location_on_outlined,
      Icons.bookmark_border,
    ];

    return Row(
      children: List.generate(icons.length, (i) {
        final active = selected == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            width: 64,
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? const Color(0xFF6B1F8A) : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Icon(
              icons[i],
              size: 24,
              color: active ? const Color(0xFF6B1F8A) : Colors.black38,
            ),
          ),
        );
      }),
    );
  }
}

class _PostsGrid extends StatefulWidget {
  final void Function(int count) onPostsLoaded;
  const _PostsGrid({required this.onPostsLoaded});

  @override
  State<_PostsGrid> createState() => _PostsGridState();
}

class _PostsGridState extends State<_PostsGrid> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/post/user/$userId?viewer_id=$userId'));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final posts = List<Map<String, dynamic>>.from(data['posts']);
        setState(() => _posts = posts);
        widget.onPostsLoaded(posts.length);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.purple));
    }
    if (_posts.isEmpty) {
      return const Center(
        child: Text('게시물 없음', style: TextStyle(fontSize: 15, color: Colors.grey)),
      );
    }
    return GridView.builder(
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
        final imageUrl = '${ApiConstants.baseUrl}${post['post_image']}';
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
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFFD9D9D9)),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  const _EmptyTab({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon, size: 48, color: Colors.black12));
  }
}
