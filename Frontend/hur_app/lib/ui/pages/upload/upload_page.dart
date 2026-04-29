import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            const MainHeader(title: '게시물 작성'),
            SizedBox(height: 10),
            Container(
              height: 1,
              color: const Color.fromARGB(255, 206, 206, 206),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 36, 30, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사진 업로드',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 328,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffcccccc)),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.file_upload_outlined,
                          size: 42,
                          color: Color(0xffbbbbbb),
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    const Text(
                      '퍼스널 컬러',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
                        Expanded(child: _ColorButton(text: '봄 웜톤')),
                        SizedBox(width: 18),
                        Expanded(child: _ColorButton(text: '여름 쿨톤')),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(child: _ColorButton(text: '가을 웜톤')),
                        SizedBox(width: 18),
                        Expanded(child: _ColorButton(text: '겨울 쿨톤')),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      '설명',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xffcccccc),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xffcccccc),
                          ),
                        ),
                      ),
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

class _ColorButton extends StatelessWidget {
  final String text;

  const _ColorButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color(0xffcccccc)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(text),
      ),
    );
  }
}
