import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/home_post_more_popup.dart';
import 'package:hur_app/ui/common/widget/side_drawer.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'detail/detail_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = '발견';
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/post/feed'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts = List<Map<String, dynamic>>.from(data['posts']);
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = <Map<String, dynamic>>[];
    final rightItems = <Map<String, dynamic>>[];
    for (int i = 0; i < _posts.length; i++) {
      if (i.isEven) {
        leftItems.add(_posts[i]);
      } else {
        rightItems.add(_posts[i]);
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const SideDrawer(),
        body: Column(
          children: [
            MainHeader(
              bottom: _HomeHeader(
                selectedTab: selectedTab,
                onTapTab: (tab) {
                  setState(() {
                    selectedTab = tab;
                  });
                },
              ),
            ),

            Container(
              height: 1,
              color: const Color.fromARGB(255, 206, 206, 206),
            ),

            Expanded(
              child: selectedTab == '발견'
                  ? _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.purple,
                            ),
                          )
                        : _posts.isEmpty
                        ? const Center(
                            child: Text(
                              '게시물이 없습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            child: SingleChildScrollView(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: leftItems.map((post) {
                                        final imageUrl =
                                            '${ApiConstants.baseUrl}${post['post_image']}';
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DetailHomePage(
                                                  imageUrl: imageUrl,
                                                  nickname:
                                                      post['nickname'] ?? '',
                                                  title: post['title'] ?? '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: _ImageCard(
                                            imageUrl: imageUrl,
                                            label: post['nickname'],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Column(
                                      children: rightItems.map((post) {
                                        final imageUrl =
                                            '${ApiConstants.baseUrl}${post['post_image']}';
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DetailHomePage(
                                                  imageUrl: imageUrl,
                                                  nickname:
                                                      post['nickname'] ?? '',
                                                  title: post['title'] ?? '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: _ImageCard(
                                            imageUrl: imageUrl,
                                            label: post['nickname'],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  : const Center(
                      child: Text(
                        '팔로우 화면입니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTapTab;

  const _HomeHeader({required this.selectedTab, required this.onTapTab});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Symbols.menu,
                size: 25,
                color: Colors.black,
                weight: 400,
              ),
            ),
          ),

          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HeaderTab(
                  text: '발견',
                  selected: selectedTab == '발견',
                  onTap: () => onTapTab('발견'),
                ),
                const SizedBox(width: 20),
                _HeaderTab(
                  text: '팔로우',
                  selected: selectedTab == '팔로우',
                  onTap: () => onTapTab('팔로우'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알림 기능은 준비 중입니다.')),
                  ),
                  icon: const Icon(
                    Symbols.notifications_none,
                    size: 28,
                    color: Colors.black,
                    weight: 400,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.purple : Colors.black,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: 42,
              height: 2,
              color: selected ? Colors.purple : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imageUrl;
  final String? label;

  const _ImageCard({required this.imageUrl, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(color: const Color(0xFFEEEEEE)),
                );
              },
              errorBuilder: (context, error, stackTrace) => AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(color: const Color(0xFFEEEEEE)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: label != null
                      ? Text(
                          label!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showPostMoreOptions(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
