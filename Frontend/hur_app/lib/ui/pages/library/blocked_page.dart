//  ————————————————————————————————
//  |        차단됨 / 제한됨          |
//  ————————————————————————————————

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/auth_utils.dart';
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedPage extends StatefulWidget {
  const BlockedPage({super.key});

  @override
  State<BlockedPage> createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      try {
        final res = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/user/me/blocks'),
          headers: {'Authorization': 'Bearer $_token'},
        );
        if (!mounted) return;
        if (res.statusCode == 401) {
          await handleUnauthorized(context);
          return;
        }
        if (res.statusCode == 200) {
          setState(() => _users = List<Map<String, dynamic>>.from(jsonDecode(res.body)));
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _release(Map<String, dynamic> user) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/user/${user['id']}/block'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _users.removeWhere((u) => u['id'] == user['id']));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['nickname']}님을 해제했어요.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('해제하지 못했어요. 인터넷 연결을 확인해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: AppBar(
        backgroundColor: HurColors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: HurColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '차단됨',
          style: TextStyle(color: HurColors.text, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HurColors.accent))
          : _token == null
              ? const Center(
                  child: Text('로그인하면 볼 수 있어요.', style: TextStyle(fontSize: 15, color: HurColors.muted)),
                )
              : _users.isEmpty
                  ? const Center(
                      child: Text('차단하거나 제한한 계정이 없어요.', style: TextStyle(fontSize: 15, color: HurColors.muted)),
                    )
                  : ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, thickness: 1, color: HurColors.line),
                      itemBuilder: (_, i) {
                        final u = _users[i];
                        final isBlock = u['kind'] == 'block';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: HurColors.surfaceStrong,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: HurColors.muted),
                          ),
                          title: Text(
                            u['nickname'] ?? '',
                            style: const TextStyle(color: HurColors.text, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            isBlock ? '차단됨' : '제한됨',
                            style: const TextStyle(color: HurColors.muted, fontSize: 12),
                          ),
                          trailing: OutlinedButton(
                            onPressed: () => _release(u),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HurColors.text,
                              side: const BorderSide(color: HurColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('해제', style: TextStyle(fontSize: 13)),
                          ),
                        );
                      },
                    ),
    );
  }
}
