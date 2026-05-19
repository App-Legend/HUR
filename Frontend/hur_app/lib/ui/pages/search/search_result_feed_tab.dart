//  ————————————————————————————————
//  |        검색 후 피드 탭         |
//  ————————————————————————————————

import 'package:flutter/material.dart';

class SearchResultFeedTab extends StatelessWidget {
  const SearchResultFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    const images = [
      'assets/images/search/search1.jpg',
      'assets/images/search/search2.jpg',
      'assets/images/search/search3.jpg',
      'assets/images/search/search4.jpg',
      'assets/images/search/search5.jpg',
      'assets/images/search/search6.jpg',
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.asset(images[index], fit: BoxFit.cover);
      },
    );
  }
}
