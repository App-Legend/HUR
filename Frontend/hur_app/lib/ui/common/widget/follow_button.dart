import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;
  final bool onDark;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: onDark ? 28 : 14,
          vertical: onDark ? 10 : 6,
        ),
        decoration: BoxDecoration(
          color: onDark
              ? (isFollowing ? Colors.white38 : const Color(0xFF6B1F8A))
              : (isFollowing ? const Color(0xff8b5cf6) : Colors.white),
          border: onDark ? null : Border.all(color: const Color(0xff8b5cf6)),
          borderRadius: BorderRadius.circular(onDark ? 24 : 20),
        ),
        child: Text(
          isFollowing ? '팔로잉' : '팔로우',
          style: TextStyle(
            fontSize: onDark ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: onDark
                ? Colors.white
                : (isFollowing ? Colors.white : const Color(0xff8b5cf6)),
          ),
        ),
      ),
    );
  }
}
