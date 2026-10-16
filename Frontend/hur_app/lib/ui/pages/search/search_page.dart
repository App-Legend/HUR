import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hur_app/app/constants.dart';
import 'search_result_accounts_tab.dart';
import 'search_result_cosmetics_tab.dart';
import 'search_result_feed_tab.dart';
import 'package:hur_app/app/theme.dart';

class SearchPage extends StatefulWidget {
  final FocusNode? focusNode;
  const SearchPage({super.key, this.focusNode});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final FocusNode _searchFocusNode;
  late final bool _ownsNode;
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchFocused = false;
  bool _hasSearched = false;
  late String _trendingUpdatedAt;

  // 로그인한 유저의 최근 검색어 (서버 저장). 로그인 전이면 비어 있다.
  List<String> _recentKeywords = [];

  // 서버에서 급상승 검색어를 받아오기 전/실패 시에 보여줄 기본값
  List<List<String>> _trending = _defaultTrending.map((e) => List<String>.from(e)).toList();

  static const _defaultTrending = [
    ['1', '선크림', '-'],
    ['2', '립', 'up'],
    ['3', '포켓몬', 'down'],
    ['4', '비디오션', '-'],
    ['5', '쿠션', '-'],
    ['6', '클렌징밀크', '-'],
    ['7', '페리페라', 'up'],
    ['8', '포켓몬 에디션', 'down'],
    ['9', '네일', '-'],
    ['10', '샴푸', '-'],
  ];

  @override
  void initState() {
    super.initState();
    _ownsNode = widget.focusNode == null;
    _searchFocusNode = widget.focusNode ?? FocusNode();
    _tabController = TabController(length: 3, vsync: this);
    _trendingUpdatedAt = _nowLabel();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      // 검색창을 누를 때마다 최신 상태로 (로그인 직후 등 토큰이 바뀐 경우 대비)
      if (_searchFocusNode.hasFocus) _loadRecent();
    });

    _loadRecent();
    _loadTrending();
  }

  String _nowLabel() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return (token == null || token.isEmpty) ? null : token;
  }

  Future<void> _loadRecent() async {
    final token = await _getToken();
    if (token == null) {
      if (mounted) setState(() => _recentKeywords = []);
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/search/recent'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200 && mounted) {
        final keywords = List<String>.from(jsonDecode(res.body)['keywords']);
        setState(() => _recentKeywords = keywords);
      }
    } catch (_) {}
  }

  Future<void> _loadTrending() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/search/trending'));
      if (res.statusCode == 200 && mounted) {
        final list = jsonDecode(res.body)['keywords'] as List;
        if (list.isEmpty) return;
        setState(() {
          _trending = list
              .map<List<String>>((e) => ['${e['rank']}', '${e['keyword']}', '${e['status']}'])
              .toList();
          _trendingUpdatedAt = _nowLabel();
        });
      }
    } catch (_) {}
  }

  // 검색 기록은 실패해도 검색 자체를 막지 않는다.
  Future<void> _logSearch(String keyword) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/search/log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'keyword': keyword}),
      );
    } catch (_) {}
    await _loadRecent();
  }

  Future<void> _deleteRecent(String keyword) async {
    setState(() => _recentKeywords.remove(keyword));
    final token = await _getToken();
    if (token == null) return;
    try {
      await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/search/recent/${Uri.encodeComponent(keyword)}'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {}
  }

  Future<void> _clearRecent() async {
    setState(() => _recentKeywords = []);
    final token = await _getToken();
    if (token == null) return;
    try {
      await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/search/recent'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_ownsNode) _searchFocusNode.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void resetSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _hasSearched = false;
      _searchController.clear();
    });
    _loadRecent();
    _loadTrending();
  }

  void _onSubmitted(String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) return;
    _searchController.text = keyword;
    setState(() {
      _hasSearched = true;
    });
    _searchFocusNode.unfocus();
    _logSearch(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearchFocused && !_hasSearched,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_isSearchFocused) {
            _searchFocusNode.unfocus();
          } else if (_hasSearched) {
            setState(() {
              _hasSearched = false;
              _searchController.clear();
            });
          }
        }
      },
      child: Container(
        color: HurColors.panel,
        child: SafeArea(
          child: Column(
            children: [
              // 검색창 영역
              Container(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 14),
                decoration: BoxDecoration(
                  color: HurColors.panel,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: HurColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSubmitted,
                    style: const TextStyle(color: HurColors.text),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: HurColors.muted,
                      ),
                      filled: true,
                      fillColor: HurColors.surfaceStrong,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              // 검색 결과 탭
              if (_hasSearched)
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: HurColors.accent,
                        unselectedLabelColor: HurColors.muted,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(fontSize: 14),
                        indicatorColor: HurColors.accent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: HurColors.surfaceStrong,
                        tabs: const [
                          Tab(text: '화장품'),
                          Tab(text: '계정'),
                          Tab(text: '피드'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SearchResultCosmeticsTab(query: _searchController.text.trim()),
                            SearchResultAccountsTab(query: _searchController.text.trim()),
                            SearchResultFeedTab(query: _searchController.text.trim()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 포커스 시 검색 기록
              if (!_hasSearched && _isSearchFocused)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _recentKeywords.length,
                    itemBuilder: (context, index) {
                      final keyword = _recentKeywords[index];
                      return _SearchHistoryItem(
                        text: keyword,
                        onTap: () => _onSubmitted(keyword),
                      );
                    },
                  ),
                ),

              // 기본 화면 (최근/급상승 검색어)
              if (!_hasSearched && !_isSearchFocused)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_recentKeywords.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '최근 검색어',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: HurColors.text,
                                ),
                              ),
                              GestureDetector(
                                onTap: _clearRecent,
                                child: const Text(
                                  '전체 삭제',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: HurColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _recentKeywords.map((keyword) {
                              return _RecentKeywordChip(
                                text: keyword,
                                onTap: () => _onSubmitted(keyword),
                                onDelete: () => _deleteRecent(keyword),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 42),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '급상승 검색어',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: HurColors.text,
                              ),
                            ),
                            Text(
                              '$_trendingUpdatedAt 기준',
                              style: const TextStyle(
                                fontSize: 10,
                                color: HurColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: _trending
                                    .take(5)
                                    .map(
                                      (item) => _TrendingKeywordItem(
                                        rank: item[0],
                                        keyword: item[1],
                                        status: item[2],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: Column(
                                children: _trending
                                    .skip(5)
                                    .map(
                                      (item) => _TrendingKeywordItem(
                                        rank: item[0],
                                        keyword: item[1],
                                        status: item[2],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHistoryItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SearchHistoryItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: HurColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: HurColors.text),
              ),
            ),
            const Icon(Icons.call_made, size: 16, color: HurColors.muted),
          ],
        ),
      ),
    );
  }
}

class _RecentKeywordChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecentKeywordChip({
    required this.text,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: HurColors.panel,
        border: Border.all(color: HurColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(
              text,
              style: const TextStyle(fontSize: 10, color: HurColors.muted),
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Symbols.close,
              size: 12,
              color: HurColors.muted,
              weight: 400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingKeywordItem extends StatelessWidget {
  final String rank;
  final String keyword;
  final String status;

  const _TrendingKeywordItem({
    required this.rank,
    required this.keyword,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              rank,
              style: const TextStyle(fontSize: 11, color: HurColors.text),
            ),
          ),
          Expanded(
            child: Text(
              keyword,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: HurColors.text),
            ),
          ),
          _StatusIcon(status: status),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'up') {
      return const Icon(
        Symbols.arrow_drop_up,
        size: 18,
        color: HurColors.peach,
        weight: 700,
      );
    }

    if (status == 'down') {
      return const Icon(
        Symbols.arrow_drop_down,
        size: 18,
        color: Colors.blue,
        weight: 700,
      );
    }

    return const Text(
      '-',
      style: TextStyle(fontSize: 11, color: HurColors.muted),
    );
  }
}
