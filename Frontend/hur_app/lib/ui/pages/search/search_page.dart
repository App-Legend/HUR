import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'search_result_accounts_tab.dart';
import 'search_result_cosmetics_tab.dart';
import 'search_result_feed_tab.dart';

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
  late final String _trendingUpdatedAt;

  final List<String> _recentKeywords = ['틴트', '워터밤 비오틴'];

  static const _trendingKeywords = [
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

  final _searchSuggestions = ['선크림', '립글로스', '쿠션 파운데이션', '클렌징밀크', '틴트', '비오틴 샴푸'];

  @override
  void initState() {
    super.initState();
    _ownsNode = widget.focusNode == null;
    _searchFocusNode = widget.focusNode ?? FocusNode();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _trendingUpdatedAt = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
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
  }

  void _onSubmitted(String value) {
    if (value.trim().isEmpty) return;
    setState(() {
      _hasSearched = true;
    });
    _searchFocusNode.unfocus();
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
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // 검색창 영역
              Container(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    color: const Color(0xfff4f4f4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSubmitted,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xfff4f4f4),
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
                        labelColor: const Color(0xFF6B1F8A),
                        unselectedLabelColor: const Color(0xff9b9b9b),
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(fontSize: 14),
                        indicatorColor: const Color(0xFF6B1F8A),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: const Color(0xffe5e5e5),
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
                    itemCount: _searchSuggestions.length,
                    itemBuilder: (context, index) {
                      return _SearchHistoryItem(text: _searchSuggestions[index]);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '최근 검색어',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _recentKeywords.clear()),
                              child: const Text(
                                '전체 삭제',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xffc4c4c4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: _recentKeywords.map((keyword) {
                            return _RecentKeywordChip(
                              text: keyword,
                              onDelete: () => setState(() => _recentKeywords.remove(keyword)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 42),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '급상승 검색어',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$_trendingUpdatedAt 기준',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xffc4c4c4),
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
                                children: _trendingKeywords
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
                                children: _trendingKeywords
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

  const _SearchHistoryItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Color(0xffbdbdbd)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
          const Icon(Icons.call_made, size: 16, color: Color(0xffbdbdbd)),
        ],
      ),
    );
  }
}

class _RecentKeywordChip extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const _RecentKeywordChip({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e5e5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: Color(0xff9b9b9b)),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Symbols.close,
              size: 12,
              color: Color(0xffbdbdbd),
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
              style: const TextStyle(fontSize: 11, color: Colors.black),
            ),
          ),
          Expanded(
            child: Text(
              keyword,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black),
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
        color: Colors.red,
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
      style: TextStyle(fontSize: 11, color: Color(0xffbdbdbd)),
    );
  }
}
