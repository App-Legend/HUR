import 'package:flutter/material.dart';

const _purple = Color(0xFF7B2D8B);

const _options = [
  ('💄', '13~17호'),
  ('💄', '21호'),
  ('💄', '23호'),
  ('💄', '25호'),
];

class OnboardingSkinTone extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingSkinTone({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 56),
            const Text(
              '당신이 좋아하는\n피부톤은 무엇인가요?',
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
              'What skin tone do you like?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: _options
                  .map((opt) => _Chip(
                        emoji: opt.$1,
                        label: opt.$2,
                        selected: selected == opt.$2,
                        onTap: () => onSelect(opt.$2),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 140,
              height: 48,
              child: _Chip(
                emoji: '💄',
                label: '27호',
                selected: selected == '27호',
                onTap: () => onSelect('27호'),
              ),
            ),
            const Spacer(),
            _ContinueButton(enabled: selected != null, onTap: onNext),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onSkip,
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? _purple : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? _purple : const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Center(
          child: Text(
            '계속하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
