import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/pages/home/comment_popup.dart';
import 'package:hur_app/ui/pages/home/product_tag_popup.dart';
import 'package:hur_app/ui/pages/home/purchase_popup.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLiked = false;
  bool isBookmark = true;
  int likeCount = 234;
  int bookmarkCount = 10;
  bool showProductIcons = false;
  bool showProductPopup = false;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void _toggleBookmark() {
    setState(() {
      isBookmark = !isBookmark;
      bookmarkCount -= isBookmark ? 1 : -1;
    });
  }

  void _showCommentPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
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
      barrierColor: Colors.black.withOpacity(0.35),
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
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: () {},
              ),
              showDivider: false,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: .fromLTRB(12, 3, 24, 3),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xffdddddd),
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '닉네임',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '팔로우',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showProductIcons = !showProductIcons;
                          showProductPopup = false;
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 460,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showProductIcons = !showProductIcons;
                                  showProductPopup = false;
                                });
                              },
                              child: Image.asset(
                                'assets/images/home/home1.jpg',
                                width: double.infinity,
                                height: 460,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              left: 210,
                              top: 145,
                              child: IgnorePointer(
                                ignoring: !showProductIcons,
                                child: AnimatedOpacity(
                                  opacity: showProductIcons ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        showProductPopup = !showProductPopup;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 34,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 145,
                              top: 215,
                              child: IgnorePointer(
                                ignoring: !showProductIcons,
                                child: AnimatedOpacity(
                                  opacity: showProductIcons ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        showProductPopup = !showProductPopup;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 34,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (showProductPopup)
                              const Positioned(
                                left: 170,
                                top: 250,
                                child: ProductTagPopup(
                                  imagePath:
                                      'assets/images/ranking/detail1.jpg',
                                  brandName: '립 포션',
                                  productName: '카라멜 글레이즈',
                                  price: '18,900원~',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: .fromLTRB(16, 18, 18, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.black,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            '$likeCount',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(width: 18),

                          GestureDetector(
                            onTap: _showCommentPopup,
                            child: const Icon(
                              Icons.mode_comment_outlined,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            '12',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),

                          SizedBox(width: 18),

                          GestureDetector(
                            onTap: _toggleBookmark,
                            child: Icon(
                              isBookmark
                                  ? Icons.bookmark_outline
                                  : Icons.bookmark,
                              color: Colors.black,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            '$bookmarkCount',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
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
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffeeeeee),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '#봄웜톤',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffeeeeee),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '#봄웜톤',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffeeeeee),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '#봄웜톤',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Icon(
                                Icons.sell_outlined,
                                color: Colors.black,
                                size: 25,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '사용한 제품',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: .bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: .all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffedc8ef),
                                ),
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 12,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 14),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 3,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff7f7f7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Image.asset(
                                            'assets/images/ranking/detail1.jpg',
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '얼터너티브스테레오',
                                                style: TextStyle(
                                                  color: Color(0xffaaaaaa),
                                                  fontSize: 10,
                                                ),
                                              ),

                                              SizedBox(height: 2),

                                              Text(
                                                '립 포션 카라멜 글레이즈',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        const Text(
                                          '18,900원~',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        GestureDetector(
                                          onTap: _showPurchasePopup,
                                          child: const Icon(
                                            Icons.open_in_new,
                                            color: Color(0xffc9c9c9),
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
