import 'package:flutter/material.dart' hide RankingPage;
import 'package:hur_app/ui/pages/profile/guest_profile.dart';
import 'package:hur_app/ui/pages/profile/profile.dart';
import 'package:hur_app/ui/pages/ranking/ranking_page.dart';
import 'package:hur_app/ui/pages/search/search_page.dart';
import 'package:hur_app/ui/pages/upload/upload_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/navigation/bottom_nav.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<SearchPageState> _searchPageKey = GlobalKey<SearchPageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const RankingPage(),
      UploadPage(onPostSuccess: () => setState(() => _currentIndex = 0)),
      SearchPage(key: _searchPageKey, focusNode: _searchFocusNode),
    ];
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isLoggedIn = prefs.getInt('user_id') != null);
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget currentPage = _currentIndex == 4
        ? (_isLoggedIn ? const MyPage() : const ProfilePage())
        : _pages[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,

      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: SafeArea(
          bottom: false,
          child: Column(children: [Expanded(child: currentPage)]),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex && index == 3) {
            _searchPageKey.currentState?.resetSearch();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
