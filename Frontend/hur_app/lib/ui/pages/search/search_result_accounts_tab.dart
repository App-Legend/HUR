//  ————————————————————————————————
//  |        검색 후 계정 탭         |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/ui/common/widget/follow_button.dart';

import 'package:hur_app/app/constants.dart';

class SearchResultAccountsTab extends StatefulWidget {
  final String query;
  const SearchResultAccountsTab({super.key, required this.query});

  @override
  State<SearchResultAccountsTab> createState() => _SearchResultAccountsTabState();
}

class _SearchResultAccountsTabState extends State<SearchResultAccountsTab> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  @override
  void didUpdateWidget(SearchResultAccountsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _fetchUsers();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('user_id');
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/user/search/users').replace(queryParameters: {
        'q': widget.query,
        if (_myId != null) 'me': _myId.toString(),
      });
      final response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        final List data = jsonDecode(response.body);
        setState(() {
          _accounts = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow(int index) async {
    if (_myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인을 해주세요')),
      );
      return;
    }
    final account = _accounts[index];
    final targetId = account['id'];
    final isFollowing = account['is_following'] as bool;

    // 낙관적 업데이트 (API 응답 전에 UI 먼저 변경)
    setState(() => _accounts[index]['is_following'] = !isFollowing);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/user/$targetId/follow');
      final response = isFollowing
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
        // 실패 시 롤백
        setState(() => _accounts[index]['is_following'] = isFollowing);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요청에 실패했어요')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _accounts[index]['is_following'] = isFollowing);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_accounts.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없어요', style: TextStyle(color: Colors.black38, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        return _AccountItem(
          nickname: account['nickname'] ?? '',
          username: account['username'] ?? '',
          profileImage: account['profile_image'],
          isFollowing: account['is_following'] as bool? ?? false,
          onFollowToggle: () => _toggleFollow(index),
        );
      },
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String nickname;
  final String username;
  final String? profileImage;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _AccountItem({
    required this.nickname,
    required this.username,
    required this.profileImage,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xffe0e0e0),
            backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
            child: profileImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text('@$username', style: const TextStyle(fontSize: 11, color: Color(0xff9b9b9b))),
              ],
            ),
          ),
          FollowButton(isFollowing: isFollowing, onTap: onFollowToggle),
        ],
      ),
    );
  }
}
