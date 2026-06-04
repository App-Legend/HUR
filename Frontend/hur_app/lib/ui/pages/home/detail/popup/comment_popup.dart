//  ————————————————————————————————
//  |          댓글창 팝업           |
//  ————————————————————————————————

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';

class CommentPopup extends StatefulWidget {
  final int postId;
  final int? userId;
  final VoidCallback? onCommentAdded;

  const CommentPopup({
    super.key,
    required this.postId,
    this.userId,
    this.onCommentAdded,
  });

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/comments'),
      );
      if (res.statusCode == 200 && mounted) {
        final List data = jsonDecode(res.body);
        setState(() {
          _comments = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.userId == null || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();
    _focusNode.unfocus();

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId, 'content': text}),
      );
      if (res.statusCode == 201 && mounted) {
        final comment = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _comments.add(comment));
        widget.onCommentAdded?.call();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/post/${widget.postId}/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId}),
      );
      if (mounted) {
        setState(() => _comments.removeWhere((c) => c['comment_id'] == commentId));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
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
                    Text(
                      '댓글 ${_comments.length}개',
                      style: const TextStyle(
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(
                            child: Text('첫 댓글을 남겨보세요!',
                                style: TextStyle(color: Colors.black38)),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 18),
                            itemCount: _comments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 22),
                            itemBuilder: (context, index) {
                              final c = _comments[index];
                              final isMyComment =
                                  c['user_id'] == widget.userId;
                              return GestureDetector(
                                onLongPress: isMyComment
                                    ? () => showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            content:
                                                const Text('댓글을 삭제할까요?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  _deleteComment(
                                                      c['comment_id']);
                                                },
                                                child: const Text('삭제',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        )
                                    : null,
                                child: _CommentItem(comment: c),
                              );
                            },
                          ),
              ),
              const Divider(height: 1, color: Color(0xffeeeeee)),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: widget.userId == null
                              ? '로그인 후 댓글을 남길 수 있어요'
                              : '댓글을 입력하세요...',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Color(0xffaaaaaa)),
                          filled: true,
                          fillColor: const Color(0xfff5f5f5),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: widget.userId != null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendComment,
                      child: _isSending
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff690673)),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Color(0xff690673), size: 26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    final profileImage = comment['profile_image'] as String?;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: const Color(0xffdddddd),
          backgroundImage:
              profileImage != null ? NetworkImage(profileImage) : null,
          child: profileImage == null
              ? const Icon(Icons.person, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment['nickname'] ?? '',
                style: const TextStyle(
                    color: Color(0xff888888),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                comment['content'] ?? '',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
