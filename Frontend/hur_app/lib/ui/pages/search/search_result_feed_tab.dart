import 'package:flutter/material.dart';

class SearchResultFeedTab extends StatelessWidget {
  const SearchResultFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xfff5c5c5),
      Color(0xfffce8e8),
      Color(0xfff0d0d8),
      Color(0xffffd9d9),
      Color(0xffe8c5cc),
      Color(0xfffff0f4),
      Color(0xfff5d5e0),
      Color(0xfffce4ec),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        return Container(color: colors[index]);
      },
    );
  }
}
