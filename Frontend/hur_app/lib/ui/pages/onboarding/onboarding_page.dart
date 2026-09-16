import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_page.dart';
import 'widgets/onboarding_welcome.dart';
import 'widgets/onboarding_color.dart';
import 'widgets/onboarding_skin_tone.dart';
import 'widgets/onboarding_aesthetic.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  String? _color;
  String? _skinTone;

  void _next() => _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OnboardingWelcome(onNext: _next),
          OnboardingColor(
            selected: _color,
            onSelect: (v) => setState(() => _color = v),
            onNext: _next,
            onSkip: _finish,
          ),
          OnboardingSkinTone(
            selected: _skinTone,
            onSelect: (v) => setState(() => _skinTone = v),
            onNext: _next,
            onSkip: _finish,
          ),
          OnboardingAesthetic(onFinish: _finish),
        ],
      ),
    );
  }
}
