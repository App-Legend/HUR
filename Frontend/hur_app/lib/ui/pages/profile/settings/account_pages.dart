//  ————————————————————————————————
//  |  계정 설정 하위 화면            |
//  |  로그인정보/비밀번호/알림 설정   |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/notification_prefs.dart';
import 'package:hur_app/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppBar _appBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: HurColors.bg,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: HurColors.text, size: 20),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: const TextStyle(color: HurColors.text, fontSize: 17, fontWeight: FontWeight.w600),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: HurColors.line),
    ),
  );
}

// 가입 때와 같은 규칙: 8자 이상 + 영문 소문자 + 숫자 + 특수문자(@$!%*?&)
bool isValidPassword(String pw) =>
    pw.length >= 8 && RegExp(r'^(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(pw);

const passwordRuleHint = '8자 이상, 영문 소문자·숫자·특수문자(@\$!%*?&) 포함';

InputDecoration passwordDecoration(String hint, {Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: HurColors.muted, fontSize: 15),
    suffixIcon: suffix,
    filled: true,
    fillColor: HurColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: HurColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: HurColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: HurColors.accent, width: 1.5),
    ),
  );
}

// ───────────────────────── 로그인정보 ─────────────────────────

class LoginInfoPage extends StatefulWidget {
  const LoginInfoPage({super.key});

  @override
  State<LoginInfoPage> createState() => _LoginInfoPageState();
}

class _LoginInfoPageState extends State<LoginInfoPage> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      try {
        final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/user/$userId'));
        if (res.statusCode == 200 && mounted) {
          setState(() => _user = jsonDecode(res.body));
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _gender(String? g) => switch (g) {
        'male' => '남성',
        'female' => '여성',
        'other' => '기타',
        _ => '-',
      };

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final birth = (u?['birth_date'] as String?)?.split('T').first ?? '-';
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: _appBar(context, '로그인정보'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HurColors.accent))
          : u == null
              ? const Center(
                  child: Text('로그인하면 확인할 수 있어요.', style: TextStyle(color: HurColors.muted)),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    _InfoRow('이메일 (아이디)', u['email'] ?? '-'),
                    _InfoRow('이름', u['name'] ?? '-'),
                    _InfoRow('닉네임', u['nickname'] ?? '-'),
                    _InfoRow('성별', _gender(u['gender'] as String?)),
                    _InfoRow('생년월일', birth),
                  ],
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: HurColors.muted, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: HurColors.text, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── 비밀번호 변경 ─────────────────────────

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_current.text.isEmpty) return _toast('현재 비밀번호를 입력해주세요.');
    if (!isValidPassword(_next.text)) return _toast('새 비밀번호는 $passwordRuleHint 이어야 해요.');
    if (_next.text != _confirm.text) return _toast('새 비밀번호가 서로 달라요.');

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/auth/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token')}',
        },
        body: jsonEncode({'current_password': _current.text, 'new_password': _next.text}),
      );
      if (!mounted) return;
      if (res.statusCode == 401) {
        await handleUnauthorized(context);
        return;
      }
      final message = (jsonDecode(res.body) as Map)['message'] as String?;
      if (res.statusCode == 200) {
        _toast(message ?? '비밀번호를 변경했어요.');
        Navigator.pop(context);
        return;
      }
      _toast(message ?? '비밀번호를 변경하지 못했어요.');
    } catch (_) {
      if (mounted) _toast('인터넷 연결을 확인해주세요.');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final eye = IconButton(
      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: HurColors.muted, size: 20),
      onPressed: () => setState(() => _obscure = !_obscure),
    );
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: _appBar(context, '비밀번호 변경'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          TextField(
            controller: _current,
            obscureText: _obscure,
            style: const TextStyle(color: HurColors.text),
            decoration: passwordDecoration('현재 비밀번호', suffix: eye),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _next,
            obscureText: _obscure,
            style: const TextStyle(color: HurColors.text),
            decoration: passwordDecoration('새 비밀번호'),
          ),
          const SizedBox(height: 8),
          const Text(passwordRuleHint, style: TextStyle(color: HurColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          TextField(
            controller: _confirm,
            obscureText: _obscure,
            style: const TextStyle(color: HurColors.text),
            decoration: passwordDecoration('새 비밀번호 확인'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: HurColors.accent,
                disabledBackgroundColor: HurColors.accent.withValues(alpha: 0.4),
                foregroundColor: HurColors.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: HurColors.onAccent, strokeWidth: 2),
                    )
                  : const Text('변경하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── 알림 설정 ─────────────────────────

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<String, bool> _enabled = {for (final k in notificationPrefKeys.keys) k: true};

  static const _labels = {
    'like': ('좋아요', '내 게시물에 좋아요가 눌렸을 때'),
    'comment': ('댓글', '내 게시물에 댓글이 달렸을 때'),
    'follow': ('팔로우', '누군가 나를 팔로우했을 때'),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final e in notificationPrefKeys.entries) {
        _enabled[e.key] = prefs.getBool(e.value) ?? true;
      }
    });
  }

  Future<void> _set(String type, bool value) async {
    setState(() => _enabled[type] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationPrefKeys[type]!, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: _appBar(context, '알림 설정'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final type in notificationPrefKeys.keys)
            SwitchListTile(
              value: _enabled[type] ?? true,
              onChanged: (v) => _set(type, v),
              activeThumbColor: HurColors.accent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              title: Text(_labels[type]!.$1,
                  style: const TextStyle(color: HurColors.text, fontSize: 16)),
              subtitle: Text(_labels[type]!.$2,
                  style: const TextStyle(color: HurColors.muted, fontSize: 13)),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              '끈 종류의 알림은 알림 화면과 벨 표시에서 보이지 않아요. 이 기기에만 적용돼요.',
              style: TextStyle(color: HurColors.muted, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
