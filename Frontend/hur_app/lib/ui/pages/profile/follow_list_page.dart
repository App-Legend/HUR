//  ————————————————————————————————
//  |     팔로워 / 팔로잉 목록        |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'feed/user_feed_page.dart';

import 'package:hur_app/app/constants.dart';

class FollowListPage extends StatefulWidget {
  final int userId;
  final bool isFollowers; // true = 팔로워, false = 팔로잉

  const FollowListPage({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList() async {
    final type = widget.isFollowers ? 'followers' : 'following';
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}/follow/$type'),
      );
      if (response.statusCode == 200 && mounted) {
        final List data = jsonDecode(response.body);
        setState(() {
          _users = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFollowers ? '팔로워' : '팔로잉';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Text(
                    widget.isFollowers ? '팔로워가 없어요' : '팔로잉한 계정이 없어요',
                    style: const TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _UserItem(
                      user: user,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserFeedPage(userId: user['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _UserItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  const _UserItem({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final profileImage = user['profile_image'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
            child: profileImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 26)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['nickname'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user['username'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
