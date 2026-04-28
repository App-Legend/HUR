import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController? controller;
  final int selectedTab;
  final ValueChanged<int>? onTabChanged;

  const SearchHeader({
    super.key,
    this.controller,
    this.selectedTab = 0,
    this.onTabChanged,
  });

  static const _tabs = ['화장품', '계정', '피드'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff1f1f1),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 34,
              ),
              hintText: '제품, 계정, 피드 검색',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        Row(
          children: List.generate(
            _tabs.length,
            (i) => Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged?.call(i),
                child: _SearchTabItem(
                  text: _tabs[i],
                  selected: selectedTab == i,
                ),
              ),
            ),
          ),
        ),
        Container(height: 1, color: const Color(0xffdddddd)),
      ],
    );
  }
}

class _SearchTabItem extends StatelessWidget {
  final String text;
  final bool selected;

  const _SearchTabItem({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 22,
            color: selected ? Colors.purple : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 3,
          color: selected ? Colors.purple : Colors.transparent,
        ),
      ],
    );
  }
}
