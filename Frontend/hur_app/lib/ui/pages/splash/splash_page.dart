import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:hur_app/ui/pages/main_page.dart';
import 'package:hur_app/ui/pages/onboarding/onboarding_page.dart';

// 영상이 이 시간 안에 안 끝나거나(기기별 코덱 문제 등) 아예 로드에 실패해도
// 무조건 다음 화면으로 넘어가게 하는 안전장치. 실제 영상 길이보다 넉넉하게 잡음.
const _maxSplashDuration = Duration(seconds: 5);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _initVideo();
    Future.delayed(_maxSplashDuration, _navigate);
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset('assets/splash/splash_movie.mp4');
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      controller.addListener(_onVideoProgress);
      setState(() => _controller = controller);
      await controller.play();
    } catch (e) {
      // 영상을 못 열어도 앱 진입 자체는 막지 않는다 — 안전장치 타이머가 곧 넘겨준다.
      debugPrint('[splash] 영상 로드 실패: $e');
    }
  }

  void _onVideoProgress() {
    final controller = _controller;
    if (controller == null || _navigated) return;
    final value = controller.value;
    if (!value.isInitialized) return;
    if (value.duration > Duration.zero && value.position >= value.duration) {
      _navigate();
    }
  }

  Future<void> _navigate() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => done ? const MainPage() : const OnboardingPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: controller != null && controller.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
