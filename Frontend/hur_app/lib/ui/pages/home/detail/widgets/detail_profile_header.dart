//  ————————————————————————————————
//  |   계정 헤더(닉네임/팔로우 버튼)   |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/widget/follow_button.dart';
import 'package:hur_app/ui/pages/profile/feed/user_feed_page.dart';

class DetailProfileHeader extends StatefulWidget {
  final String nickname;
  final int? userId;
  final VoidCallback onFollowTap;

  const DetailProfileHeader({
    super.key,
    required this.nickname,
    this.userId,
    required this.onFollowTap,
  });

  @override
  State<DetailProfileHeader> createState() => _DetailProfileHeaderState();
}

class _DetailProfileHeaderState extends State<DetailProfileHeader> {
  bool _isFollowing = false;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _loadMyId();
  }

  @override
  void didUpdateWidget(DetailProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId != null) {
      _loadFollowStatus();
    }
  }

  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('user_id');
    if (mounted) setState(() {});
    if (widget.userId != null && _myId != null && _myId != widget.userId) {
      await _loadFollowStatus();
    }
  }

  Future<void> _loadFollowStatus() async {
    if (widget.userId == null || _myId == null) return;
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}/follow/check?me=$_myId'),
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() => _isFollowing = data['is_following'] ?? false);
      }
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    if (_myId == null || widget.userId == null) return;
    final before = _isFollowing;
    setState(() => _isFollowing = !before);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/user/${widget.userId}/follow');
      final res = before
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
      if (res.statusCode != 200 && mounted) {
        setState(() => _isFollowing = before);
      }
    } catch (_) {
      if (mounted) setState(() => _isFollowing = before);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = _myId != null && _myId == widget.userId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 24, 3),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserFeedPage(userId: widget.userId!)),
                );
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xffdddddd),
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserFeedPage(userId: widget.userId!)),
                  );
                }
              },
              child: Text(
                widget.nickname,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (!isOwnProfile && widget.userId != null)
            FollowButton(
              isFollowing: _isFollowing,
              onTap: _toggleFollow,
            ),
        ],
      ),
    );
  }
}
