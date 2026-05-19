//  ————————————————————————————————
//  |        다른 사람 프로필         |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/home_post_more_popup.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  int _selectedTab = 0;
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _UserProfileHeader(
              isFollowing: _isFollowing,
              onFollowTap: () => setState(() => _isFollowing = !_isFollowing),
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
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const _UserProfileHeader({
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB0B0B0),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showPostMoreOptions(context),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF9E9E9E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사용자',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ID: 0000',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                '0 팔로우',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(width: 20),
              Text(
                '0 받은 좋아요/찜',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '자기소개',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TagChip(label: '가을 웜톤', icon: Icons.contrast),
              const SizedBox(width: 8),
              _TagChip(label: '21호', icon: Icons.palette_outlined),
              const Spacer(),
              GestureDetector(
                onTap: onFollowTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? Colors.white38
                        : const Color(0xFF6B1F8A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    isFollowing ? '팔로잉' : '팔로우',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
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
