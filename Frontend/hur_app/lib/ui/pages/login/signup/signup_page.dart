import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';

import '../login_page.dart';
import 'package:hur_app/app/theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedPolicy = false;
  final bool _isLoading = false;
  String? _selectedGender;
  DateTime? _birthDate;

  static const _purple = HurColors.accent;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  


  void _signup() async {
    // 입력 데이터 수집
    final name = _nameController.text;
    final nickname = _nicknameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    // 성별 선택 확인
    String? gender;
    if (_selectedGender == '여성') {
      gender = 'female';
    } else if (_selectedGender == '남성') {
      gender = 'male';
    } else if (_selectedGender == '기타') {
      gender = 'other';
    }

  // 생년월일 포맷팅
    String birthDate = '';
    if (_birthDate != null) {
      birthDate = '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
    }

  // API 요청 데이터 생성
    final requestData = {
      "name": name,
      "nickname": nickname,
      "gender": gender,
      "birth": birthDate,
      "email": email,
      "password": password,
      "passwordConfirm": passwordConfirm,
    };

  try {
      // API 호출
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

    if (response.statusCode == 201) {
        // 성공 처리
        final data = jsonDecode(response.body);

        // 토큰 저장 (예: SharedPreferences)
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard()));

        // 회원가입 성공 메시지 출력
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('회원가입 성공!')));
        }
        await Future.delayed(const Duration(seconds: 2));

        // 회원가입 성공 시 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

      } else if (response.statusCode == 409) {
        // 이메일 중복 에러
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 이메일입니다')),
        );
      } else {
        // 다른 에러 처리/
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? '회원가입 실패')),
        );
      }
    } catch (e) {
      // 네트워크 에러 처리
      print('Network error: $e'); // 에러 로그 추가
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '회원가입',
                style: TextStyle(
                  color: HurColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('이름'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: '홍길동',
                prefix: const Icon(Icons.person_outline, color: HurColors.muted, size: 20),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('닉네임'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nicknameController,
                hint: '홍길동',
                prefix: const Icon(Icons.person_outline, color: HurColors.muted, size: 20),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('성별'),
                        const SizedBox(height: 8),
                        _buildGenderSelector(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('생년월일'),
                        const SizedBox(height: 8),
                        _buildBirthField(context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel('이메일 주소'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'tanyamyroniuk@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined, color: HurColors.muted, size: 20),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('비밀번호'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••',
                obscure: _obscurePassword,
                prefix: const Icon(Icons.lock_outline, color: HurColors.muted, size: 20),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: HurColors.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('비밀번호확인'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordConfirmController,
                hint: '••••••••',
                obscure: _obscureConfirm,
                prefix: const Icon(Icons.lock_outline, color: HurColors.muted, size: 20),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: HurColors.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _acceptedPolicy,
                      onChanged: (v) => setState(() => _acceptedPolicy = v ?? false),
                      activeColor: _purple,
                      checkColor: HurColors.onAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: HurColors.muted),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '개인정보 수집 및 이용 동의',
                    style: TextStyle(color: HurColors.muted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_acceptedPolicy && !_isLoading) ? _signup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor: _purple.withValues(alpha: 0.4),
                    foregroundColor: HurColors.onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: HurColors.onAccent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '회원가입',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요?  ',
                    style: TextStyle(color: HurColors.muted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['여성', '남성', '기타'];
    return Row(
      children: genders.map((g) {
        final selected = _selectedGender == g;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = g),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _purple : HurColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _purple : HurColors.border,
                ),
              ),
              child: Text(
                g,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? HurColors.onAccent : HurColors.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBirthField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime(1999, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: _purple, onPrimary: HurColors.onAccent),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _birthDate = picked);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: HurColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HurColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 17, color: HurColors.muted),
            const SizedBox(width: 8),
            Text(
              _birthDate != null
                  ? '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}'
                  : '1999.01.01',
              style: TextStyle(
                fontSize: 13,
                color: _birthDate != null ? HurColors.text : HurColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Widget prefix,
    Widget? suffix,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: HurColors.text, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: HurColors.muted, fontSize: 15),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: HurColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
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
      style: const TextStyle(color: HurColors.muted, fontSize: 13),
    );
  }
}
