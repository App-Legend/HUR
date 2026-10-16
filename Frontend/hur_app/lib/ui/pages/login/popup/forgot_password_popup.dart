import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class ForgotPasswordPopup extends StatefulWidget {
  const ForgotPasswordPopup({super.key});

  @override
  State<ForgotPasswordPopup> createState() => _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState extends State<ForgotPasswordPopup> {
  final _emailController = TextEditingController();

  static const _purple = HurColors.accent;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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

          const SizedBox(height: 28),

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
                  '비밀번호를 재설정하려는 계정(이메일)을 입력해주세요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: HurColors.muted,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '이메일 주소',
                  style: TextStyle(fontSize: 13, color: HurColors.muted),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 15, color: HurColors.text),
                  decoration: InputDecoration(
                    hintText: 'tanyamyroniuk@gmail.com',
                    hintStyle: const TextStyle(fontSize: 14, color: HurColors.muted),
                    prefixIcon: const Icon(Icons.email_outlined, color: HurColors.muted, size: 20),
                    filled: true,
                    fillColor: HurColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: HurColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _purple, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 본인인증 로직 연결
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: HurColors.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '본인인증하기',
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
    );
  }
}
