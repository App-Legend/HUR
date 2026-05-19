import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/follow_button.dart';

class SearchResultAccountsTab extends StatefulWidget {
  const SearchResultAccountsTab({super.key});

  @override
  State<SearchResultAccountsTab> createState() =>
      _SearchResultAccountsTabState();
}

class _SearchResultAccountsTabState extends State<SearchResultAccountsTab> {
  final _accounts = <Map<String, Object>>[
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': false},
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': true},
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': false},
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': false},
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': true},
    {'id': '사용자아이디', 'followers': '팔로워 000명', 'isFollowing': false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        return _AccountItem(
          userId: _accounts[index]['id'] as String,
          followers: _accounts[index]['followers'] as String,
          isFollowing: _accounts[index]['isFollowing'] as bool,
          onFollowToggle: () {
            setState(() {
              _accounts[index]['isFollowing'] = !(_accounts[index]['isFollowing'] as bool);
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
          FollowButton(
            isFollowing: isFollowing,
            onTap: onFollowToggle,
          ),
        ],
      ),
    );
  }
}
