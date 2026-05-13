import 'package:flutter/material.dart';

class SearchResultAccountsTab extends StatefulWidget {
  const SearchResultAccountsTab({super.key});

  @override
  State<SearchResultAccountsTab> createState() =>
      _SearchResultAccountsTabState();
}

class _SearchResultAccountsTabState extends State<SearchResultAccountsTab> {
  final List<bool> _following = [false, true, false, false, true, false];

  final _accounts = const [
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
    {'id': '사용자아이디', 'followers': '팔로워 000명'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        return _AccountItem(
          userId: _accounts[index]['id']!,
          followers: _accounts[index]['followers']!,
          isFollowing: _following[index],
          onFollowToggle: () {
            setState(() {
              _following[index] = !_following[index];
            });
          },
        );
      },
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String userId;
  final String followers;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _AccountItem({
    required this.userId,
    required this.followers,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xffe0e0e0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  followers,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff9b9b9b),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFollowToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isFollowing ? const Color(0xff8b5cf6) : Colors.white,
                border: Border.all(color: const Color(0xff8b5cf6)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFollowing ? '팔로잉' : '팔로우',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isFollowing ? Colors.white : const Color(0xff8b5cf6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
