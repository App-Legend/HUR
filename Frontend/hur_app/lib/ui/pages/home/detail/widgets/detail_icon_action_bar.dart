//  ————————————————————————————————
//  |      좋아요/댓글/북마크 바      |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DetailIconActionBar extends StatelessWidget {
  final bool isLiked;
  final bool isBookmark;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onBookmarkTap;

  const DetailIconActionBar({
    super.key,
    required this.isLiked,
    required this.isBookmark,
    required this.likeCount,
    required this.commentCount,
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
              Symbols.favorite,
              color: Colors.black,
              size: 26,
              weight: 400,
              fill: isLiked ? 1 : 0,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '$likeCount',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onCommentTap,
            child: Icon(
              Symbols.mode_comment,
              color: Colors.black,
              size: 26,
              weight: 400,
            ),
          ),
          const SizedBox(width: 3),
          Text('$commentCount', style: const TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onBookmarkTap,
            child: Icon(
              Symbols.bookmarks,
              color: Colors.black,
              size: 26,
              weight: 400,
              fill: isBookmark ? 0 : 1,
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
