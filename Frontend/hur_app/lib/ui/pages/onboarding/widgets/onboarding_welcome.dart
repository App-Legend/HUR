import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class OnboardingWelcome extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingWelcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HurColors.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 은은하게 번지는 빛
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 460,
                height: 460,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x29DCE2EC), Color(0x00DCE2EC)],
                    stops: [0.0, 0.66],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  const Text(
                    'HUR',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 7,
                      color: HurColors.text,
                    ),
                  ),
                  const SizedBox(height: 56),
                  // 진주 구슬
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.32, -0.44),
                        radius: 0.95,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFE6DAD4),
                          Color(0xFFB7A7A3),
                          Color(0xFF4C4146),
                          Color(0xFF1B161B),
                        ],
                        stops: [0.0, 0.22, 0.52, 0.78, 1.0],
                      ),
                      border: Border.all(color: HurColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 60,
                          offset: Offset(0, 30),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '당신이 원하는\n분위기를 만들어 드립니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: HurColors.text,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Start to creates the atmosphere\nyou want',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: HurColors.muted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(width: 36, height: 1, color: HurColors.border),
                  const SizedBox(height: 34),
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: HurColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: HurColors.onAccent,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
