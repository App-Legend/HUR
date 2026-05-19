//  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅣ          공개 대상 설정 페이지           ㅣ
//  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PublicScopePage extends StatefulWidget {
  final String selectedScope;

  const PublicScopePage({super.key, required this.selectedScope});

  @override
  State<PublicScopePage> createState() => _PublicScopePageState();
}

class _PublicScopePageState extends State<PublicScopePage> {
  late String _selectedScope;

  @override
  void initState() {
    super.initState();
    _selectedScope = widget.selectedScope;
  }

  void _selectScope(String scope) {
    setState(() {
      _selectedScope = scope;
    });

    Navigator.pop(context, scope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left, size: 34),
                    ),
                  ),
                  const Text(
                    '공개 대상',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: const Color(0xffdddddd)),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 게시물을 볼 수 있는 사람',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff888888),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _ScopeOption(
                      icon: Symbols.group,
                      title: '모든 사람',
                      selected: _selectedScope == '모든 사람',
                      onTap: () => _selectScope('모든 사람'),
                    ),

                    const SizedBox(height: 22),

                    _ScopeOption(
                      icon: Icons.star_border,
                      title: '팔로워만',
                      selected: _selectedScope == '팔로워만',
                      onTap: () => _selectScope('팔로워만'),
                    ),
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

class _ScopeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
          const Spacer(),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 24,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
