//  ————————————————————————————————
//  |          회원 설정            |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/pages/info/info_pages.dart';
import 'package:hur_app/ui/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hur_app/app/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('로그아웃', style: TextStyle(color: HurColors.peach)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: AppBar(
        backgroundColor: HurColors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: HurColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: HurColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
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
          _SettingsItem(
            label: '이용약관',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
          ),
          _SettingsItem(
            label: '개인정보처리방침',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          _SettingsItem(
            label: '오픈소스 라이선스',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'HUR',
              applicationVersion: '0.0.1',
            ),
            isLast: true,
          ),
          const SizedBox(height: 40),
          _SettingsItem(
            label: '로그아웃',
            labelColor: HurColors.peach,
            onTap: () => _logout(context),
          ),
          _SettingsItem(
            label: '회원탈퇴',
            labelColor: HurColors.peach,
            onTap: () {},
            isLast: true,
          ),
          const SizedBox(height: 20),
          const Text(
            '버전: 0.0.1',
            style: TextStyle(color: HurColors.muted, fontSize: 13),
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
        color: HurColors.text,
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
                  color: labelColor ?? HurColors.text,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: HurColors.line,
        ),
      ],
    );
  }
}
