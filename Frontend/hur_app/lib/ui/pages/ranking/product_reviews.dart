import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';

/// 상품 상세의 '후기' 탭. 우리 앱 유저가 쓴 후기를 보여주고 쓰기/삭제를 할 수 있다.
class ProductReviewTab extends StatefulWidget {
  final int? productId;

  const ProductReviewTab({super.key, required this.productId});

  @override
  State<ProductReviewTab> createState() => _ProductReviewTabState();
}

class _ProductReviewTabState extends State<ProductReviewTab> {
  List<Map<String, dynamic>> _reviews = [];
  int _count = 0;
  double? _average;
  bool _isLoading = true;
  int? _myId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');
    _token = (token == null || token.isEmpty) ? null : token;
    await _fetch();
  }

  Future<void> _fetch() async {
    final id = widget.productId;
    if (id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products/$id/reviews'),
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(data['reviews']);
          _count = data['summary']['count'] as int;
          _average = (data['summary']['average'] as num?)?.toDouble();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openWriteSheet() async {
    if (_token == null) {
      _showSnack('후기는 로그인 후 남길 수 있어요.');
      return;
    }
    final mine = _reviews.where((r) => r['user_id'] == _myId).toList();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WriteReviewSheet(
        productId: widget.productId!,
        token: _token!,
        initialRating: mine.isEmpty ? 0 : mine.first['rating'] as int,
        initialContent: mine.isEmpty ? '' : mine.first['content'] as String,
      ),
    );
    if (result == true) await _fetch();
  }

  Future<void> _deleteMine() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('후기를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: HurColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: HurColors.peach)),
          ),
        ],
      ),
    );
    if (ok != true || _token == null) return;
    try {
      await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/products/${widget.productId}/reviews'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (_) {}
    await _fetch();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productId == null) {
      return const Center(
        child: Text('후기를 불러올 수 없는 상품이에요', style: TextStyle(color: HurColors.muted, fontSize: 14)),
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasMine = _reviews.any((r) => r['user_id'] == _myId);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: [
              if (_count > 0) ...[
                const Icon(Icons.star_rounded, size: 18, color: HurColors.text),
                const SizedBox(width: 4),
                Text(
                  _average!.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text('후기 $_count개', style: const TextStyle(fontSize: 13, color: HurColors.muted)),
              ] else
                const Text('아직 후기가 없어요', style: TextStyle(fontSize: 13, color: HurColors.muted)),
              const Spacer(),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: _openWriteSheet,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: Size.zero,
                    side: const BorderSide(color: HurColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: Text(hasMine ? '내 후기 수정' : '후기 쓰기', style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _reviews.isEmpty
              ? const Center(
                  child: Text('첫 후기를 남겨보세요', style: TextStyle(color: HurColors.muted, fontSize: 14)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: _reviews.length,
                  itemBuilder: (_, i) {
                    final r = _reviews[i];
                    final isMine = r['user_id'] == _myId;
                    return _ReviewItem(
                      nickname: r['nickname'] as String? ?? '',
                      rating: r['rating'] as int,
                      content: r['content'] as String,
                      date: _formatDate(r['created_at'] as String?),
                      onDelete: isMine ? _deleteMine : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }
}

class _Stars extends StatelessWidget {
  final int rating;

  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < rating ? HurColors.text : HurColors.border,
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String nickname;
  final int rating;
  final String content;
  final String date;
  final VoidCallback? onDelete;

  const _ReviewItem({
    required this.nickname,
    required this.rating,
    required this.content,
    required this.date,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: HurColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HurColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nickname,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                SizedBox(
                  width: 44,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '내 후기 삭제',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20, color: HurColors.muted),
                  ),
                )
              else
                const SizedBox(height: 32),
            ],
          ),
          Row(
            children: [
              _Stars(rating: rating),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(fontSize: 11, color: HurColors.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5, color: HurColors.textSub),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final int productId;
  final String token;
  final int initialRating;
  final String initialContent;

  const _WriteReviewSheet({
    required this.productId,
    required this.token,
    required this.initialRating,
    required this.initialContent,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late int _rating = widget.initialRating;
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialContent);
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (_rating == 0) {
      _showSnack('별점을 선택해주세요.');
      return;
    }
    if (content.isEmpty) {
      _showSnack('후기 내용을 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/products/${widget.productId}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'rating': _rating, 'content': content}),
      );
      if (!mounted) return;
      if (res.statusCode == 201) {
        Navigator.pop(context, true);
        return;
      }
      String message = '후기 등록에 실패했어요.';
      try {
        message = jsonDecode(res.body)['message'] ?? message;
      } catch (_) {}
      _showSnack(message);
    } catch (_) {
      if (mounted) _showSnack('서버 연결에 실패했어요.');
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: HurColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: HurColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HurColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('후기 쓰기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                tooltip: '${i + 1}점',
                onPressed: () => setState(() => _rating = i + 1),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 34,
                  color: filled ? HurColors.text : HurColors.border,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(hintText: '사용해본 느낌을 남겨주세요'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: HurColors.onAccent),
                    )
                  : const Text('등록하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
