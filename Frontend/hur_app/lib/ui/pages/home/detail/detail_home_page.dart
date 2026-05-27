import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';
import 'package:hur_app/ui/pages/home/detail/popup/comment_popup.dart';
import 'package:hur_app/ui/pages/home/detail/popup/purchase_popup.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/detail_icon_action_bar.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/detail_profile_header.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/image_tag_section.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/used_product_header.dart';
import 'package:hur_app/ui/pages/home/detail/widgets/used_product_list.dart';

class DetailHomePage extends StatefulWidget {
  final String imagePath;

  const DetailHomePage({super.key, required this.imagePath});

  @override
  State<DetailHomePage> createState() => _DetailHomePage();
}

class _DetailHomePage extends State<DetailHomePage> {
  bool isLiked = false;
  bool isBookmark = true;
  int likeCount = 234;
  int bookmarkCount = 10;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void _toggleBookmark() {
    setState(() {
      isBookmark = !isBookmark;
      bookmarkCount += isBookmark ? -1 : 1;
    });
  }

  void _showCommentPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      builder: (context) {
        return const CommentPopup();
      },
    );
  }

  void _showPurchasePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: true,
      builder: (context) {
        return const PurchasePopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            MainHeader(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Color(0xff747474),
                ),
                onPressed: () {},
              ),
              showDivider: false,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DetailProfileHeader(nickname: '닉네임', onFollowTap: () {}),

                    const SizedBox(height: 12),

                    ImageTagSection(imagePath: widget.imagePath),

                    DetailIconActionBar(
                      isLiked: isLiked,
                      isBookmark: isBookmark,
                      likeCount: likeCount,
                      bookmarkCount: bookmarkCount,
                      onLikeTap: _toggleLike,
                      onCommentTap: _showCommentPopup,
                      onBookmarkTap: _toggleBookmark,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '봄 웜톤 데일리 메이크업',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            '봄 웜톤에게 잘 어울리는 따뜻한 복숭아 컬러 메이크업이에요! 데일리로 하기 좋은 자연스러운 룩입니다 💕',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: const [
                              CategoryChip(
                                text: '#봄웜톤',
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                fontSize: 12,
                                borderRadius: 20,
                              ),
                              SizedBox(width: 9),
                              CategoryChip(
                                text: '#복숭아메이크업',
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                fontSize: 12,
                                borderRadius: 20,
                              ),
                              SizedBox(width: 9),
                              CategoryChip(
                                text: '#데일리',
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                fontSize: 12,
                                borderRadius: 20,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          const UsedProductHeader(count: 3),

                          const SizedBox(height: 14),

                          UsedProductList(onOpenTap: _showPurchasePopup),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
