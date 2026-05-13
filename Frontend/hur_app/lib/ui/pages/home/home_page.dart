import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
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

  @override
  Widget build(BuildContext context) {
    final leftImages = [
      'assets/images/home/home1.jpg',
      'AD',
      'assets/images/home/home2.jpg',
      'assets/images/home/home3.jpg',
    ];

    final rightImages = [
      'assets/images/home/home4.jpg',
      'assets/images/home/home5.jpg',
      'assets/images/home/home6.jpg',
      'assets/images/home/home7.jpg',
    ];

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
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: leftImages.map((item) {
                                  if (item == 'AD') {
                                    return const _AdBox();
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailHomePage(imagePath: item),
                                        ),
                                      );
                                    },
                                    child: _ImageCard(
                                      imagePath: item,
                                      height: 160,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                children: rightImages.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailHomePage(imagePath: item),
                                        ),
                                      );
                                    },
                                    child: _ImageCard(
                                      imagePath: item,
                                      height: index == 0 ? 300 : 130,
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
                  onPressed: () {},
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
  final double height;

  const _ImageCard({required this.imagePath, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
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
