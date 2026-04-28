import 'package:flutter/material.dart';
import 'package:hur_app/ui/pages/ranking/ranking_page.dart';

import '../common/navigation/bottom_nav.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // final 빼기

  final List<Widget> _pages = [
    const HomePage(),
    const RankingPage(),
    const _PlaceholderPage(label: '업로드'),
    const _PlaceholderPage(label: '검색'),
    const _PlaceholderPage(label: '프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(children: [Expanded(child: _pages[_currentIndex])]),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;

  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }
}
