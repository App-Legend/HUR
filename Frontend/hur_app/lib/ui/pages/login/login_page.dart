import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants.dart';
import '../main_page.dart';
import 'signup/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _keepLoggedIn = false;

  // 온보딩은 로그인 전에도 볼 수 있어서 그때는 유저 ID가 없어 로컬(SharedPreferences)에만 저장해뒀다.
  // 로그인에 성공한 시점에 유저 ID가 생기니, 여기서 한 번 서버로 동기화한다.
  Future<void> _syncOnboardingPreferences(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getString('onboarding_color');
    final moodRaw = prefs.getString('onboarding_mood');
    if (color == null && moodRaw == null) return;

    final mood = moodRaw != null && moodRaw.isNotEmpty ? moodRaw.split(',').first : null;

    try {
      await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (color != null) 'personal_color': color,
          if (mood != null) 'aesthetic_tag': mood,
        }),
      );
      await prefs.remove('onboarding_color');
      await prefs.remove('onboarding_mood');
    } catch (_) {
      // 동기화 실패해도 로그인은 막지 않음 — 로컬 값을 안 지웠으니 다음 로그인 때 다시 시도됨
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'keep_logged_in': _keepLoggedIn}),
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', body['token']);
        await prefs.setInt('user_id', body['user']['id']);
        await prefs.setString('user_name', body['user']['name']);
        await _syncOnboardingPreferences(body['user']['id']);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? body['error'] ?? '로그인에 실패했어요.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 연결에 실패했어요.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '로그인',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('이메일 주소'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: _inputDecoration(
                  hint: 'example@gmail.com',
                  prefix: const Icon(
                    Icons.email_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('비밀번호'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: _inputDecoration(
                  hint: '••••••••',
                  prefix: const Icon(
                    Icons.lock_outline,
                    color: Colors.black38,
                    size: 20,
                  ),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black38,
                      size: 20,
                    ),
                    onPressed:
                        () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _keepLoggedIn,
                          onChanged: (v) => setState(() => _keepLoggedIn = v ?? false),
                          activeColor: const Color(0xFF6B1F8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('로그인 유지', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B1F8A),
                    disabledBackgroundColor:
                        const Color(0xFF6B1F8A).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'login with',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    onTap: () {},
                    child: const Icon(
                      Icons.apple,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 24),
                  _SocialButton(
                    onTap: () {},
                    child: ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFF9ED32),
                              Color(0xFFEE2A7B),
                              Color(0xFF002AFF),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ).createShader(bounds),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _SocialButton(
                    onTap: () {},
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '아직 계정이 없나요?  ',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Color(0xFF6B1F8A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainPage()),
                  ),
                  child: const Text(
                    '비회원으로 시작하기',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Widget prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6B1F8A), width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12, width: 1.5),
          color: Colors.white,
        ),
        child: Center(child: child),
      ),
    );
  }
}
