import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 24.0),
    (Icons.leaderboard_outlined, Icons.leaderboard, 24.0),
    (Icons.add_circle_outline, Icons.add_circle, 32.0),
    (Icons.search, Icons.search, 24.0),
    (Icons.person_outline, Icons.person, 24.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 0.5, color: const Color(0xFFDDDDDD)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  final (inactiveIcon, activeIcon, size) = _items[i];
                  final isSelected = currentIndex == i;
                  return GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 56,
                      child: Center(
                        child: Icon(
                          isSelected ? activeIcon : inactiveIcon,
                          size: size,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
