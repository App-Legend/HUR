import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';

const _purple = Color(0xFF7B2D8B);

class OnboardingAesthetic extends StatefulWidget {
  final ValueChanged<List<String>> onFinish;

  const OnboardingAesthetic({super.key, required this.onFinish});

  @override
  State<OnboardingAesthetic> createState() => _OnboardingAestheticState();
}

class _OnboardingAestheticState extends State<OnboardingAesthetic> {
  final Set<int> _selected = {};
  List<String> _images = [];
  bool _loadingImages = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/post/feed')
          .replace(queryParameters: {'random': 'true'});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = List<Map<String, dynamic>>.from(data['posts']);
        final urls = posts
            .where((p) => p['post_image'] != null)
            .map((p) => '${ApiConstants.baseUrl}${p['post_image']}' as String)
            .toList();
        if (mounted) setState(() => _images = urls);
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingImages = false);
  }

  void _toggle(int i) => setState(() {
        if (_selected.contains(i)) {
          _selected.remove(i);
        } else {
          _selected.add(i);
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
                itemCount: _loadingImages ? 6 : _images.length,
                itemBuilder: (context, i) {
                  final isSelected = _selected.contains(i);

                  return GestureDetector(
                    onTap: () => _toggle(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_loadingImages || i >= _images.length)
                            Container(color: const Color(0xFFEEEEEE))
                          else
                            Image.network(_images[i], fit: BoxFit.cover),
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
                onTap: () => widget.onFinish([]),
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
