import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LikesTab extends StatelessWidget {
  const LikesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xffefc6f2),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}
