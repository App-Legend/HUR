import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';

const _purple = Color(0xFF7B2D8B);

const _moods = ['청순', '시크', '큐티', '섹시', '차분'];

class OnboardingAesthetic extends StatefulWidget {
  final ValueChanged<List<String>> onFinish;

  const OnboardingAesthetic({super.key, required this.onFinish});

  @override
  State<OnboardingAesthetic> createState() => _OnboardingAestheticState();
}

class _OnboardingAestheticState extends State<OnboardingAesthetic> {
  final Set<String> _selected = {};
  final Map<String, String?> _moodImages = {};
  bool _loadingImages = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodImages();
  }

  Future<void> _fetchMoodImages() async {
    await Future.wait(_moods.map((mood) async {
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}/post/feed')
            .replace(queryParameters: {'mood': mood, 'page': '0'});
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final posts = List<Map<String, dynamic>>.from(data['posts']);
          if (posts.isNotEmpty) {
            final imageUrl = '${ApiConstants.baseUrl}${posts.first['post_image']}';
            if (mounted) setState(() => _moodImages[mood] = imageUrl);
          }
        }
      } catch (_) {}
    }));
    if (mounted) setState(() => _loadingImages = false);
  }

  void _toggle(String mood) => setState(() {
        if (_selected.contains(mood)) {
          _selected.remove(mood);
        } else {
          _selected.add(mood);
        }
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Text(
              '자신의 추구미와\n맞는 분위기를 골라주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please select a mood that matches your\naesthetic aspirations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, i) {
                  final mood = _moods[i];
                  final isSelected = _selected.contains(mood);
                  final imageUrl = _moodImages[mood];

                  return GestureDetector(
                    onTap: () => _toggle(mood),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_loadingImages || imageUrl == null)
                            Container(color: const Color(0xFFEEEEEE))
                          else
                            Image.network(imageUrl, fit: BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Text(
                                mood,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            Container(color: _purple.withValues(alpha: 0.3)),
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: _purple,
                                child: Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
              child: GestureDetector(
                onTap: () => widget.onFinish(_selected.toList()),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Center(
                    child: Text(
                      '시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
