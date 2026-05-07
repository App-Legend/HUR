import 'package:flutter/material.dart';

class CommentPopup extends StatelessWidget {
  const CommentPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.35,
      maxChildSize: 0.93,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 이 부분을 잡고 위로 올리는 느낌
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    const Text(
                      '댓글 56개',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              const Divider(height: 1, color: Color(0xffeeeeee)),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  itemCount: 20,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 22);
                  },
                  itemBuilder: (context, index) {
                    return const CommentItem();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xffdddddd),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '닉네임',
                style: TextStyle(
                  color: Color(0xff888888),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                '아무댓글아무댓글아무댓글아무댓글',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                '답글',
                style: TextStyle(color: Color(0xff999999), fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        const Column(
          children: [
            Icon(Icons.favorite_border, size: 22, color: Color(0xff777777)),

            SizedBox(height: 2),

            Text(
              '12',
              style: TextStyle(color: Color(0xff777777), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
