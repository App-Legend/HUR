import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/onboarding/widgets/step_dots.dart';

// (피부톤 대표색, 호수)
const _options = [
  (Color(0xFFF5DFD0), '13~17호'),
  (Color(0xFFEBCBB1), '21호'),
  (Color(0xFFDDB896), '23호'),
  (Color(0xFFC99B76), '25호'),
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
            const SizedBox(height: 28),
            const StepDots(current: 2),
            const SizedBox(height: 52),
            const Text(
              '당신이 좋아하는\n피부톤은 무엇인가요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: HurColors.text,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What skin tone do you like?',
              style: TextStyle(fontSize: 13, color: HurColors.muted),
            ),
            const SizedBox(height: 44),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: _options
                  .map((opt) => _Chip(
                        dot: opt.$1,
                        label: opt.$2,
                        selected: selected == opt.$2,
                        onTap: () => onSelect(opt.$2),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 150,
              height: 48,
              child: _Chip(
                dot: const Color(0xFFB0805C),
                label: '27호',
                selected: selected == '27호',
                onTap: () => onSelect('27호'),
              ),
            ),
            const Spacer(),
            _ContinueButton(enabled: selected != null, onTap: onNext),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 44),
                foregroundColor: HurColors.muted,
              ),
              child: const Text('Skip for now', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Color dot;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.dot,
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
          color: selected ? HurColors.accent : HurColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? HurColors.accent : HurColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? HurColors.onAccent : HurColors.text,
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
          color: enabled ? HurColors.accent : HurColors.surfaceStrong,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            '계속하기',
            style: TextStyle(
              color: enabled ? HurColors.onAccent : HurColors.muted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
