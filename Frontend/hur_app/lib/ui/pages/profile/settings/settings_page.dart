//  ————————————————————————————————
//  |          회원 설정            |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/login_page.dart';

import 'package:hur_app/app/config/api_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 28),
          _SectionHeader('일반'),
          const SizedBox(height: 12),
          _SettingsItem(label: '로그인정보', onTap: () {}),
          _SettingsItem(label: '나의 맞춤 정보', onTap: () {}),
          _SettingsItem(label: '아이디/비밀번호 변경', onTap: () {}),
          _SettingsItem(label: '알림', onTap: () {}, isLast: true),
          const SizedBox(height: 32),
          _SectionHeader('정보'),
          const SizedBox(height: 12),
          _SettingsItem(label: '이용약관', onTap: () {}),
          _SettingsItem(label: '개인정보처리방침', onTap: () {}),
          _SettingsItem(label: '오픈소스 라이선스', onTap: () {}, isLast: true),
          const SizedBox(height: 40),
          _SettingsItem(
            label: '로그아웃',
            labelColor: const Color(0xFFE53935),
            onTap: () => _logout(context),
          ),
          _SettingsItem(
            label: '회원탈퇴',
            labelColor: const Color(0xFFE53935),
            onTap: () {},
            isLast: true,
          ),
          const SizedBox(height: 20),
          const Text(
            '버전: 0.0.1',
            style: TextStyle(color: Colors.black38, fontSize: 13),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsItem({
    required this.label,
    required this.onTap,
    this.labelColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isLast ? const Color(0xFFD0D0D0) : const Color(0xFFEEEEEE),
        ),
      ],
    );
  }
}
