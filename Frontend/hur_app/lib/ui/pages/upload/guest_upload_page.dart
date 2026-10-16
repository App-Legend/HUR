import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/pages/login/login_page.dart';
import 'package:hur_app/app/theme.dart';

class UploadLoginGate extends StatelessWidget {
  const UploadLoginGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: HurColors.panel,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const MainHeader(
                title: '게시물 작성',
                padding: EdgeInsets.fromLTRB(18, 20, 18, 20),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(),
                    const Icon(
                      Icons.edit_outlined,
                      size: 72,
                      color: HurColors.muted,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '로그인이 필요해요',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: HurColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '글 작성은 로그인 후 이용할 수 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: HurColors.muted,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HurColors.accent,
                          foregroundColor: HurColors.onAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '로그인 하기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
