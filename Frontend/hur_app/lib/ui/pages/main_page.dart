import 'package:flutter/material.dart' hide RankingPage;
import 'package:hur_app/ui/pages/profile/profile_page.dart';
import 'package:hur_app/ui/pages/ranking/ranking_page.dart';
import 'package:hur_app/ui/pages/search/search_page.dart';
import 'package:hur_app/ui/pages/upload/upload_page.dart';

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
    const UploadPage(),
    const SearchPage(),
    const ProfilePage(),
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
