import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/profile/settings/account_pages.dart';

// 비밀번호 재설정 (시연용): 이메일 인증을 보낼 수 없어서, 가입한 이메일과 이름이 맞으면 새 비밀번호로 바꿔준다.
class ForgotPasswordPopup extends StatefulWidget {
  const ForgotPasswordPopup({super.key});

  @override
  State<ForgotPasswordPopup> createState() => _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState extends State<ForgotPasswordPopup> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reset() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    if (email.isEmpty || name.isEmpty) return _toast('가입한 이메일과 이름을 입력해주세요.');
    if (!isValidPassword(_passwordController.text)) {
      return _toast('새 비밀번호는 $passwordRuleHint 이어야 해요.');
    }
    if (_passwordController.text != _confirmController.text) {
      return _toast('새 비밀번호가 서로 달라요.');
    }

    setState(() => _isSaving = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'new_password': _passwordController.text,
        }),
      );
      if (!mounted) return;
      final message = (jsonDecode(res.body) as Map)['message'] as String?;
      if (res.statusCode == 200) {
        _toast(message ?? '비밀번호를 재설정했어요.');
        Navigator.pop(context);
        return;
      }
      _toast(message ?? '비밀번호를 재설정하지 못했어요.');
    } catch (_) {
      if (mounted) _toast('인터넷 연결을 확인해주세요.');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13, color: HurColors.muted)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HurColors.panel,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),

            // 상단 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Expanded(
                    child: Text(
                      '비밀번호 재설정  |  Hur',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: HurColors.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: HurColors.surfaceStrong,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: HurColors.muted),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HurColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '가입한 이메일과 이름이 맞으면 새 비밀번호로 바꿀 수 있어요.',
                    style: TextStyle(fontSize: 13, color: HurColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 22),

                  _label('이메일 주소'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15, color: HurColors.text),
                    decoration: passwordDecoration('가입한 이메일'),
                  ),
                  const SizedBox(height: 14),

                  _label('이름'),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15, color: HurColors.text),
                    decoration: passwordDecoration('가입할 때 입력한 이름'),
                  ),
                  const SizedBox(height: 14),

                  _label('새 비밀번호'),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 15, color: HurColors.text),
                    decoration: passwordDecoration('새 비밀번호'),
                  ),
                  const SizedBox(height: 6),
                  const Text(passwordRuleHint, style: TextStyle(fontSize: 12, color: HurColors.muted)),
                  const SizedBox(height: 14),

                  _label('새 비밀번호 확인'),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 15, color: HurColors.text),
                    decoration: passwordDecoration('새 비밀번호 확인'),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _reset,
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
                          : const Text(
                              '비밀번호 재설정',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
