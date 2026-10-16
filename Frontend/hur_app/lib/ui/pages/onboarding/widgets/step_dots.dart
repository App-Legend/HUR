import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

/// 온보딩 진행 표시. [current]는 0부터 시작한다.
class StepDots extends StatelessWidget {
  final int current;
  final int total;

  const StepDots({super.key, required this.current, this.total = 4});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return Container(
          width: 22,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == current ? HurColors.accent : HurColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
