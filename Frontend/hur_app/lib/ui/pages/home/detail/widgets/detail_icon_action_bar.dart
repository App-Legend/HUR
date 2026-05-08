import 'package:flutter/material.dart';

class DetailIconActionBar extends StatelessWidget {
  final bool isLiked;
  final bool isBookmark;
  final int likeCount;
  final int bookmarkCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onBookmarkTap;

  const DetailIconActionBar({
    super.key,
    required this.isLiked,
    required this.isBookmark,
    required this.likeCount,
    required this.bookmarkCount,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLikeTap,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '$likeCount',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(width: 18),

          GestureDetector(
            onTap: onCommentTap,
            child: const Icon(
              Icons.mode_comment_outlined,
              color: Colors.black,
              size: 25,
            ),
          ),
          const SizedBox(width: 3),
          const Text('12', style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(width: 18),

          GestureDetector(
            onTap: onBookmarkTap,
            child: Icon(
              isBookmark ? Icons.bookmark_outline : Icons.bookmark,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '$bookmarkCount',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
