//  ————————————————————————————————
//  |        검색 후 피드 탭         |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/pages/home/detail/detail_home_page.dart';

class SearchResultFeedTab extends StatefulWidget {
  final String query;

  const SearchResultFeedTab({super.key, required this.query});

  @override
  State<SearchResultFeedTab> createState() => _SearchResultFeedTabState();
}

class _SearchResultFeedTabState extends State<SearchResultFeedTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts(widget.query);
  }

  @override
  void didUpdateWidget(SearchResultFeedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchPosts(widget.query);
    }
  }

  Future<void> _fetchPosts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/post/search'
              '?q=${Uri.encodeComponent(query)}',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts = List<Map<String, dynamic>>.from(data['posts']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '검색 결과를 불러오지 못했습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '서버에 연결할 수 없습니다';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xffbdbdbd)),
            const SizedBox(height: 12),
            Text(
              "'${widget.query}' 관련 게시물이 없어요",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final leftItems = <Map<String, dynamic>>[];
    final rightItems = <Map<String, dynamic>>[];
    for (int i = 0; i < _posts.length; i++) {
      if (i.isEven) {
        leftItems.add(_posts[i]);
      } else {
        rightItems.add(_posts[i]);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftItems.map((post) => _buildPostCard(post)).toList(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: rightItems.map((post) => _buildPostCard(post)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final imageUrl = '${ApiConstants.baseUrl}${post['post_image']}';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailHomePage(
            imageUrl: imageUrl,
            nickname: post['nickname'] ?? '',
            title: post['title'] ?? '',
            postId: post['post_id'] as int,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ColoredBox(color: Color(0xFFEEEEEE)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ColoredBox(color: Color(0xFFEEEEEE)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 0, 0),
              child: Text(
                post['nickname'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
