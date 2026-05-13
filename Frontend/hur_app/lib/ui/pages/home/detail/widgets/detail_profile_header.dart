import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/follow_button.dart';
import 'package:hur_app/ui/pages/profile/feed/user_feed_page.dart';

class DetailProfileHeader extends StatefulWidget {
  final String nickname;
  final VoidCallback onFollowTap;

  const DetailProfileHeader({
    super.key,
    required this.nickname,
    required this.onFollowTap,
  });

  @override
  State<DetailProfileHeader> createState() => _DetailProfileHeaderState();
}

class _DetailProfileHeaderState extends State<DetailProfileHeader> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 24, 3),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserFeedPage()),
            ),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserFeedPage()),
              ),
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

          FollowButton(
            isFollowing: _isFollowing,
            onTap: () {
              setState(() => _isFollowing = !_isFollowing);
              widget.onFollowTap();
            },
          ),
        ],
      ),
    );
  }
}
