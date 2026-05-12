import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentKeywords = ['틴트', '워터밤 비오틴'];

    final trendingKeywords = [
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

    return Container(
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
                    color: Colors.black.withOpacity(0.08),
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
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,

                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',

                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey,
                      ),

                      filled: true,
                      fillColor: Color(0xfff4f4f4),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 최근 검색어 제목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '최근 검색어',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '전체 삭제',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xffc4c4c4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 최근 검색어 칩
                    Wrap(
                      spacing: 6,
                      children: recentKeywords.map((keyword) {
                        return _RecentKeywordChip(text: keyword);
                      }).toList(),
                    ),

                    const SizedBox(height: 42),

                    // 급상승 검색어 제목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '급상승 검색어',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '00:00 기준',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xffc4c4c4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 급상승 검색어 2열
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: trendingKeywords
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
                            children: trendingKeywords
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
    );
  }
}

class _RecentKeywordChip extends StatelessWidget {
  final String text;

  const _RecentKeywordChip({required this.text});

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
          const Icon(
            Symbols.close,
            size: 12,
            color: Color(0xffbdbdbd),
            weight: 400,
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
