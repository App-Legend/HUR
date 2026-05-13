import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hur_app/ui/pages/upload/product_tag_page.dart';
import 'package:hur_app/ui/pages/upload/widgets/tag_section.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_image_box.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_input_box.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_menu_row.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:hur_app/ui/pages/upload/widgets/public_scope_page.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String _publicScope = '모든 사람';

  final Set<String> _selectedTags = {};

  final List<String> _personalColors = ['봄 웜톤', '가을 웜톤', '겨울 쿨톤', '여름쿨톤'];
  final List<String> _moods = ['청순', '시크', '큐티', '섹시', '차분'];
  final List<String> _skinTones = ['13호 ~ 17호', '21호', '23호', '25호', '27호'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _openPublicScopePage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PublicScopePage(selectedScope: _publicScope),
      ),
    );

    if (result == null) return;

    setState(() {
      _publicScope = result;
    });
  }

  void _openProductTagPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductTagPage(selectedImage: _selectedImage),
      ),
    );
  }

  void _submitPost() {
    if (_selectedTags.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추구미 태그를 최소 3개 이상 선택해주세요.')));
      return;
    }

    // TODO: 게시물 저장 로직
  }

  void _openProductDetail() {
    // TODO: 제품 상세 페이지 연결
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
              child: const MainHeader(
                title: '게시물 작성',
                padding: EdgeInsets.fromLTRB(18, 20, 18, 20),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사진',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          UploadImageBox(
                            selectedImage: _selectedImage,
                            onTap: _pickImage,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      '제목',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    UploadInputBox(controller: _titleController),

                    const SizedBox(height: 14),

                    const Text(
                      '설명',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    UploadInputBox(
                      controller: _descriptionController,
                      height: 130,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        const Text(
                          '추구미 태그',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '최소 3개 선택',
                          style: TextStyle(
                            fontSize: 11,
                            color: _selectedTags.length >= 3
                                ? Colors.green
                                : const Color(0xffaaaaaa),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TagSection(
                      title: '퍼스널 컬러',
                      tags: _personalColors,
                      selectedTags: _selectedTags,
                      onTap: _toggleTag,
                    ),

                    const SizedBox(height: 14),

                    TagSection(
                      title: '분위기',
                      tags: _moods,
                      selectedTags: _selectedTags,
                      onTap: _toggleTag,
                    ),

                    const SizedBox(height: 14),

                    TagSection(
                      title: '피부 톤',
                      tags: _skinTones,
                      selectedTags: _selectedTags,
                      onTap: _toggleTag,
                    ),

                    const SizedBox(height: 28),

                    UploadMenuRow(
                      icon: Symbols.location_on,
                      title: '제품 태그',
                      onTap: _openProductTagPage,
                    ),

                    const SizedBox(height: 18),

                    UploadMenuRow(
                      icon: Symbols.visibility_lock,
                      title: '공개 대상',
                      value: _publicScope,
                      onTap: _openPublicScopePage,
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '사용한 제품',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openProductTagPage,
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 18),
                              SizedBox(width: 4),
                              Text(
                                '제품 추가',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ProductItemContainer(
                      imagePath: 'assets/images/ranking/rank1.png',
                      brandName: '얼터너티브스테레오',
                      productName: '립 포션 카라멜 글레이즈',
                      price: '17,000원',
                      trailingIcon: Symbols.more_horiz,
                      onOpenTap: _openProductDetail,
                    ),

                    ProductItemContainer(
                      imagePath: 'assets/images/ranking/ranking5.jpg',
                      brandName: '퓌',
                      productName: '로즈 옵세션 스테이핏 틴트',
                      price: '18,000원',
                      trailingIcon: Symbols.more_horiz,
                      onOpenTap: _openProductDetail,
                    ),

                    ProductItemContainer(
                      imagePath: 'assets/images/ranking/ranking7.jpg',
                      brandName: '헤라',
                      productName: '센슈얼 누드 글로스',
                      price: '40,000원',
                      trailingIcon: Symbols.more_horiz,
                      onOpenTap: _openProductDetail,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff9c27b0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('게시하기'),
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
