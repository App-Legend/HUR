import 'package:flutter/material.dart';

class UploadHeader extends StatelessWidget {
  const UploadHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '게시물 작성',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Container(height: 1, color: const Color(0xffdddddd)),
      ],
    );
  }
}
