import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onSettings;

  const ProfileHeader({super.key, this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 18, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '프로필',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: onSettings ?? () {},
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.purple,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0xffdddddd)),
      ],
    );
  }
}
