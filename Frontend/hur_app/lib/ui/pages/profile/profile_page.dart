import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = List.generate(9, (index) => index);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5),
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
              children: const [
                Expanded(
                  child: _ProfileTab(
                    icon: Icons.grid_on_outlined,
                    text: '게시물',
                    selected: false,
                  ),
                ),
                Expanded(
                  child: _ProfileTab(
                    icon: Icons.favorite_border,
                    text: '좋아요',
                    selected: true,
                  ),
                ),
                Expanded(
                  child: _ProfileTab(
                    icon: Icons.bookmark_border,
                    text: '저장됨',
                    selected: false,
                  ),
                ),
              ],
            ),

            Container(height: 1, color: const Color(0xffeeeeee)),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                itemCount: posts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffd9d9d9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

class _ProfileTab extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;

  const _ProfileTab({
    required this.icon,
    required this.text,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.black : const Color(0xffcfcfcf),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.black : const Color(0xffcfcfcf),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            height: 3,
            width: 90,
            color: selected ? Colors.black : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
