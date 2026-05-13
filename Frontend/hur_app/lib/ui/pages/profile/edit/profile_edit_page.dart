import 'package:flutter/material.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '변경',
              style: TextStyle(
                color: Color(0xFF6B1F8A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            _ProfileImageSection(),
            const SizedBox(height: 20),
            _EditCard(
              items: [
                _EditRow(label: '이름', value: '사용자'),
                _EditRow(label: 'ID', value: '사용자'),
                _EditRow(
                  label: '배경 이미지',
                  trailing: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _EditCard(
              items: [
                _EditRow(label: '소개', value: '사용자'),
                _EditRow(label: '태그', valueWidget: const Text(
                  '자세히 보기',
                  style: TextStyle(color: Colors.black38, fontSize: 15),
                )),
              ],
            ),
            const SizedBox(height: 14),
            _EditCard(
              items: [
                _EditRow(label: '성별', value: '여성'),
                _EditRow(label: '생일', value: '0000-00-00'),
                _EditRow(label: '퍼스널컬러', value: '가을 웜톤'),
                _EditRow(label: '피부톤', value: '21호'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFD0D0D0),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCard extends StatelessWidget {
  final List<Widget> items;

  const _EditCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFF0F0F0),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  const _EditRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: trailing != null
                  ? Align(alignment: Alignment.centerLeft, child: trailing)
                  : valueWidget ??
                      Text(
                        value ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
