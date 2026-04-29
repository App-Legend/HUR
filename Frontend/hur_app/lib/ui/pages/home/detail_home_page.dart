import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            MainHeader(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: () {},
              ),
              showDivider: false,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),

            Image.asset(
              'assets/images/home/home1.jpg',
              width: double.infinity,
              height: 460,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xffdddddd),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '닉네임',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '2시간 전',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('팔로우'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '봄 웜톤 데일리 메이크업',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '봄 웜톤에게 잘 어울리는 따뜻한 복숭아 컬러 메이크업이에요! 데일리로 하기 좋은 자연스러운 룩입니다 💕',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffeeeeee),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '#봄웜톤',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
