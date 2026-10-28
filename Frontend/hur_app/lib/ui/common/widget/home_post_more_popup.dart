import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _reportReasons = ['스팸/광고', '부적절한 내용', '저작권/도용', '기타'];

/// 게시물 `...` 메뉴: 신고 / 제한 / 차단 / 공유.
/// 내 게시물이면 공유만 보여준다. 제한·차단을 하면 [onChanged]를 불러서 목록을 새로고침하게 한다.
/// 프로필 화면에서는 [postId]와 [title]을 null로 넘긴다. (게시물 신고는 빼고, 프로필을 공유한다.)
Future<void> showPostMoreOptions(
  BuildContext context, {
  required int? postId,
  required int? authorId,
  required String nickname,
  required String? title,
  VoidCallback? onChanged,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return;
  final actions = _PostMoreActions(
    context: context,
    token: prefs.getString('auth_token'),
    isMine: authorId != null && authorId == prefs.getInt('user_id'),
    postId: postId,
    authorId: authorId,
    nickname: nickname,
    title: title,
    onChanged: onChanged,
  );
  actions.showMenu();
}

class _PostMoreActions {
  final BuildContext context;
  final String? token;
  final bool isMine;
  final int? postId;
  final int? authorId;
  final String nickname;
  final String? title;
  final VoidCallback? onChanged;

  _PostMoreActions({
    required this.context,
    required this.token,
    required this.isMine,
    required this.postId,
    required this.authorId,
    required this.nickname,
    required this.title,
    required this.onChanged,
  });

  void _toast(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  bool _requireLogin() {
    if (token != null) return true;
    _toast('로그인이 필요한 기능이에요.');
    return false;
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        void run(VoidCallback action) {
          Navigator.pop(sheetContext);
          action();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HurColors.panel,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      if (!isMine) ...[
                        if (postId != null) ...[
                          _MoreOptionItem(
                            label: '신고',
                            color: HurColors.peach,
                            onTap: () => run(_report),
                          ),
                          const Divider(height: 1, thickness: 1, color: HurColors.line),
                        ],
                        _MoreOptionItem(
                          label: '제한',
                          onTap: () => run(_mute),
                        ),
                        const Divider(height: 1, thickness: 1, color: HurColors.line),
                        _MoreOptionItem(
                          label: '차단',
                          onTap: () => run(_block),
                        ),
                        const Divider(height: 1, thickness: 1, color: HurColors.line),
                      ],
                      _MoreOptionItem(
                        label: postId != null ? '게시물 공유하기' : '프로필 공유하기',
                        onTap: () => run(_share),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: HurColors.panel,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _MoreOptionItem(
                    label: '취소',
                    onTap: () => Navigator.pop(sheetContext),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _share() async {
    final text = postId != null
        ? 'HUR에서 $nickname님의 게시물 "$title"을(를) 확인해보세요!'
        : 'HUR에서 $nickname님의 프로필을 확인해보세요!';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _report() async {
    if (!_requireLogin()) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: HurColors.panel,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '신고 사유를 선택해주세요',
                        style: TextStyle(fontSize: 14, color: HurColors.muted),
                      ),
                    ),
                    for (final reason in _reportReasons) ...[
                      const Divider(height: 1, thickness: 1, color: HurColors.line),
                      _MoreOptionItem(
                        label: reason,
                        onTap: () => Navigator.pop(sheetContext, reason),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HurColors.panel,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _MoreOptionItem(
                  label: '취소',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/post/$postId/report'),
        headers: _headers,
        body: jsonEncode({'reason': reason}),
      );
      if (res.statusCode == 401) {
        if (context.mounted) await handleUnauthorized(context);
        return;
      }
      final message = (jsonDecode(res.body) as Map)['message'] as String?;
      _toast(res.statusCode == 200 ? '신고가 접수됐어요. 확인 후 조치할게요.' : (message ?? '신고하지 못했어요.'));
    } catch (_) {
      _toast('인터넷 연결을 확인해주세요.');
    }
  }

  Future<void> _mute() async {
    if (!_requireLogin()) return;
    if (await _setBlock('mute')) {
      _toast('$nickname님의 게시물이 발견 피드에서 보이지 않아요. 사이드 메뉴의 "차단됨"에서 되돌릴 수 있어요.');
    }
  }

  Future<void> _block() async {
    if (!_requireLogin()) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$nickname님을 차단할까요?'),
        content: const Text('이 계정의 게시물이 보이지 않고, 서로 팔로우가 해제돼요. 사이드 메뉴의 "차단됨"에서 해제할 수 있어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('차단', style: TextStyle(color: HurColors.peach)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (await _setBlock('block')) _toast('$nickname님을 차단했어요.');
  }

  Future<bool> _setBlock(String kind) async {
    if (authorId == null) return false;
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/$authorId/block'),
        headers: _headers,
        body: jsonEncode({'kind': kind}),
      );
      if (res.statusCode == 401) {
        if (context.mounted) await handleUnauthorized(context);
        return false;
      }
      if (res.statusCode == 200) {
        onChanged?.call();
        return true;
      }
      final message = (jsonDecode(res.body) as Map)['message'] as String?;
      _toast(message ?? '처리하지 못했어요.');
    } catch (_) {
      _toast('인터넷 연결을 확인해주세요.');
    }
    return false;
  }
}

class _MoreOptionItem extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MoreOptionItem({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: color ?? HurColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
