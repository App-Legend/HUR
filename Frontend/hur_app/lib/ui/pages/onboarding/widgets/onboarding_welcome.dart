import 'package:flutter/material.dart';

class OnboardingWelcome extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingWelcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF5EEFF),
            Color(0xFFDDB8F5),
            Color(0xFFB06FD8),
            Color(0xFF7B2D8B),
          ],
          stops: [0.0, 0.35, 0.6, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const Text(
                '당신이 원하는\n분위기를 만들어 드립니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Start to creates the atmosphere\nyou want',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: 36,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2D8B).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7B2D8B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
