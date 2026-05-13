import 'package:flutter/material.dart';

void showPostMoreOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _MoreOptionItem(
                    label: '신고',
                    color: const Color(0xFFE53935),
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  _MoreOptionItem(
                    label: '제한',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  _MoreOptionItem(
                    label: '차단',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  _MoreOptionItem(
                    label: '이 프로필 공유하기',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _MoreOptionItem(
                label: '취소',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MoreOptionItem extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MoreOptionItem({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
