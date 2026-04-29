import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';

import 'tabs/likes_tab.dart';
import 'tabs/posts_tab.dart';
import 'tabs/saved_tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;

  static const _tabs = ['게시물', '좋아요', '저장됨'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            MainHeader(
              title: '프로필',
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.purple,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 1,
              color: const Color.fromARGB(255, 206, 206, 206),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(
                      color: Color(0xffd9d9d9),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const Spacer(),

                  const _ProfileCount(number: '24', label: '게시물'),
                  const SizedBox(width: 32),
                  const _ProfileCount(number: '1234', label: '팔로워'),
                  const SizedBox(width: 32),
                  const _ProfileCount(number: '567', label: '팔로잉'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '사용자',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '퍼스널 컬러로 찾는 나만의 메이크업',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xfff1f1f1),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('프로필 편집'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(height: 1, color: const Color(0xffeeeeee)),

            Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: _ProfileTabItem(text: _tabs[i], selected: selected),
                  ),
                );
              }),
            ),

            Container(height: 1, color: const Color(0xffeeeeee)),

            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: const [PostsTab(), LikesTab(), SavedTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabItem extends StatelessWidget {
  final String text;
  final bool selected;

  const _ProfileTabItem({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.black : const Color(0xffcfcfcf),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 56,
            color: selected ? Colors.black : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _ProfileCount extends StatelessWidget {
  final String number;
  final String label;

  const _ProfileCount({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}
