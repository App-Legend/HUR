import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class _ScopeData {
  final IconData icon;
  final String title;
  const _ScopeData({required this.icon, required this.title});
}

const _kScopeOptions = [
  _ScopeData(icon: Symbols.group, title: '모든 사람'),
  _ScopeData(icon: Icons.star_border, title: '팔로워만'),
];

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
    Navigator.pop(context, scope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MainHeader(
              title: '공개 대상',
              titleFontSize: 18,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, size: 34),
              ),
              padding: const EdgeInsets.fromLTRB(8, 20, 18, 20),
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

                    for (int i = 0; i < _kScopeOptions.length; i++) ...[
                      _ScopeOption(
                        icon: _kScopeOptions[i].icon,
                        title: _kScopeOptions[i].title,
                        selected: _selectedScope == _kScopeOptions[i].title,
                        onTap: () => _selectScope(_kScopeOptions[i].title),
                      ),
                      if (i < _kScopeOptions.length - 1) const SizedBox(height: 22),
                    ],
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
