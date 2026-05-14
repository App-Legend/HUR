import 'package:flutter/material.dart';
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

  // TODO: 백엔드 연동 시 API 응답으로 교체 — 이미지 추가 시 이 숫자만 올려주면 됨
  //앞으로 이미지 추가 시 _totalImages 숫자만 올리면 되고, 나중에 백엔드 연동할 때는 List.generate(...) 부분을 API 응답으로 교체하면 됨
  static const int _totalImages = 20;

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드 연동 시 label을 API 응답의 username/title로 교체 (null이면 텍스트 행 미표시)라고 클로드가 말함
    const sampleLabels = <int, String>{
      1: 'Catasters',
      3: 'aesthetic.daily',
      6: 'lookbook_kr',
    };
    final allItems = List.generate(
      _totalImages,
      (i) => (
        path: 'assets/images/home/home${i + 1}.jpg',
        label: sampleLabels[i + 1],
      ),
    );

    // 짝수 인덱스 → 왼쪽 열, 홀수 인덱스 → 오른쪽 열
    final leftItems = <({String path, String? label})>[];
    final rightItems = <({String path, String? label})>[];
    for (int i = 0; i < allItems.length; i++) {
      if (i.isEven) {
        leftItems.add(allItems[i]);
      } else {
        rightItems.add(allItems[i]);
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: leftItems.map((item) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailHomePage(
                                            imagePath: item.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _ImageCard(
                                      imagePath: item.path,
                                      label: item.label,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                children: rightItems.map((item) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailHomePage(
                                            imagePath: item.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _ImageCard(
                                      imagePath: item.path,
                                      label: item.label,
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
  final String imagePath;
  final String? label;

  const _ImageCard({required this.imagePath, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.fitWidth,
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

class _AdBox extends StatelessWidget {
  const _AdBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xffd9d9d9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Text(
          'AD',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
