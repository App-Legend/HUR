import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

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
              ? (isFollowing ? HurColors.surfaceStrong : HurColors.accent)
              : (isFollowing ? HurColors.accent : Colors.transparent),
          border: onDark
              ? (isFollowing ? Border.all(color: HurColors.border) : null)
              : Border.all(color: isFollowing ? HurColors.accent : HurColors.border),
          borderRadius: BorderRadius.circular(onDark ? 24 : 20),
        ),
        child: Text(
          isFollowing ? '팔로잉' : '팔로우',
          style: TextStyle(
            fontSize: onDark ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: onDark
                ? (isFollowing ? HurColors.text : HurColors.onAccent)
                : (isFollowing ? HurColors.onAccent : HurColors.text),
          ),
        ),
      ),
    );
  }
}
