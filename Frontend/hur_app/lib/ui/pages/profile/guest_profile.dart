//  ————————————————————————————————
//  |     로그인 전 프로필 페이지      |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_page.dart';
import 'profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty && userId != null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) return const MyPage();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const MainHeader(
                title: '프로필',
                padding: EdgeInsets.fromLTRB(18, 20, 18, 20),
              ),
            ),
            Expanded(child: _NotLoggedInBody(onLoginSuccess: _checkLogin)),
          ],
        ),
      ),
    );
  }
}

class _NotLoggedInBody extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  const _NotLoggedInBody({required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.person_outline, size: 72, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 20),
          const Text(
            '로그인이 필요해요',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '게시물 저장 등 더 많은 기능을 이용하려면\n로그인 해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black45, height: 1.6),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                onLoginSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1F8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '로그인 하기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
