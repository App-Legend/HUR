//  ————————————————————————————————
//  |        다른 사람 프로필         |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/ui/common/widget/home_post_more_popup.dart';

import 'package:hur_app/app/constants.dart';

class UserFeedPage extends StatefulWidget {
  final int userId;
  const UserFeedPage({super.key, required this.userId});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  int _selectedTab = 0;
  bool _isFollowing = false;
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('user_id');
    await _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}'));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);

        bool following = false;
        if (_myId != null) {
          final checkRes = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}/follow/check?me=$_myId'),
          );
          if (checkRes.statusCode == 200) {
            following = jsonDecode(checkRes.body)['is_following'] ?? false;
          }
        }

        setState(() {
          _user = data;
          _isFollowing = following;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_myId == null) return;
    final before = _isFollowing;
    setState(() => _isFollowing = !before);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}/follow');
      final response = before
          ? await http.delete(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'follower_id': _myId}),
            )
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'follower_id': _myId}),
            );

      if (response.statusCode != 200 && mounted) {
        setState(() => _isFollowing = before);
      } else {
        _fetchUser(); // 팔로워 수 갱신
      }
    } catch (_) {
      if (mounted) setState(() => _isFollowing = before);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _UserProfileHeader(
                    user: _user,
                    isFollowing: _isFollowing,
                    onFollowTap: _toggleFollow,
                  ),
                  _FeedTabBar(
                    selected: _selectedTab,
                    onTap: (i) => setState(() => _selectedTab = i),
                  ),
                  Expanded(
                    child: _selectedTab == 0
                        ? _PostsGrid()
                        : const _EmptyTab(icon: Icons.location_on_outlined),
                  ),
                ],
              ),
      ),
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? user;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const _UserProfileHeader({
    required this.user,
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final nickname = user?['nickname'] ?? '사용자';
    final username = user?['username'] ?? '-';
    final bio = user?['bio'];
    final profileImage = user?['profile_image'] as String?;
    final backgroundImage = user?['background_image'] as String?;
    final followerCount = user?['follower_count'] ?? 0;
    final followingCount = user?['following_count'] ?? 0;
    final aestheticTag = user?['aesthetic_tag'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB0B0B0),
        image: backgroundImage != null
            ? DecorationImage(image: NetworkImage(backgroundImage), fit: BoxFit.cover)
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showPostMoreOptions(context),
                child: const Icon(Icons.more_horiz, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF9E9E9E),
                backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? const Icon(Icons.person, color: Colors.white, size: 36)
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
                  Text('@$username', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('$followerCount 팔로워', style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 20),
              Text('$followingCount 팔로잉', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio ?? '자기소개가 없습니다',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (aestheticTag != null)
                _TagChip(label: aestheticTag, icon: Icons.auto_awesome_outlined),
              const Spacer(),
              GestureDetector(
                onTap: onFollowTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: isFollowing ? Colors.white38 : const Color(0xFF6B1F8A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    isFollowing ? '팔로잉' : '팔로우',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
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
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FeedTabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _FeedTabBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.grid_on, Icons.location_on_outlined];
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
            child: Icon(icons[i], size: 24, color: active ? const Color(0xFF6B1F8A) : Colors.black38),
          ),
        );
      }),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
