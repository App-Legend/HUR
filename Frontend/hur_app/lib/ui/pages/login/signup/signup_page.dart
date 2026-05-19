import 'package:flutter/material.dart';

import '../login_page.dart';

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
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedPolicy = false;
  String? _selectedGender;
  DateTime? _birthDate;

  static const _purple = Color(0xFF6B1F8A);
  static const _lightGray = Color(0xFFF0F0F0);

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    // TODO: 실제 회원가입 로직 연결
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
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('이름'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: '홍길용',
                prefix: const Icon(Icons.person_outline, color: Colors.black38, size: 20),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('닉네임'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nicknameController,
                hint: '홍길동',
                prefix: const Icon(Icons.person_outline, color: Colors.black38, size: 20),
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
                prefix: const Icon(Icons.email_outlined, color: Colors.black38, size: 20),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('비밀번호'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••',
                obscure: _obscurePassword,
                prefix: const Icon(Icons.lock_outline, color: Colors.black38, size: 20),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('비밀번호확인'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: '••••••••',
                obscure: _obscureConfirm,
                prefix: const Icon(Icons.lock_outline, color: Colors.black38, size: 20),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black38,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '개인정보 수집 및 이용 동의',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _acceptedPolicy ? _signup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor: _purple.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
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
                    style: TextStyle(color: Colors.black54, fontSize: 14),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _purple : Colors.black26,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                g,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? _purple : Colors.black54,
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
              colorScheme: const ColorScheme.light(primary: _purple),
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
          color: _lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 17, color: Colors.black38),
            const SizedBox(width: 8),
            Text(
              _birthDate != null
                  ? '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}'
                  : '1999.01.01',
              style: TextStyle(
                fontSize: 13,
                color: _birthDate != null ? Colors.black87 : Colors.black38,
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
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: _lightGray,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    );
  }
}
