import 'package:flutter/material.dart';

class DetailHomeHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onShare;

  const DetailHomeHeader({super.key, this.onBack, this.onShare});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: onBack ?? () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: onShare ?? () {},
          ),
        ],
      ),
    );
  }
}
