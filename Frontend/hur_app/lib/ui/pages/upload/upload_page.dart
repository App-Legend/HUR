import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hur_app/app/constants.dart';
import 'package:hur_app/ui/common/headers/main_header.dart';
import 'package:hur_app/ui/pages/upload/product_search_sheet.dart';
import 'package:hur_app/ui/pages/upload/widgets/public_scope_page.dart';
import 'package:hur_app/ui/pages/upload/widgets/tag_section.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_image_box.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_input_box.dart';
import 'package:hur_app/ui/pages/upload/widgets/upload_menu_row.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guest_upload_page.dart';

class _StickerData {
  double xRatio;
  double yRatio;
  final String brandName;
  final String productName;
  final String? imagePath;

  _StickerData({
    required this.xRatio,
    required this.yRatio,
    required this.brandName,
    required this.productName,
    this.imagePath,
  });
}

class UploadPage extends StatefulWidget {
  final VoidCallback? onPostSuccess;
  const UploadPage({super.key, this.onPostSuccess});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool? _isLoggedIn;
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  final GlobalKey _imageKey = GlobalKey();

  final List<_StickerData> _stickers = [];
  int? _draggingIndex;
  int? _tappedStickerIndex;
  bool _overTrash = false;

  String _publicScope = '모든 사람';

  final Set<String> _selectedPersonalColors = {};
  final Set<String> _selectedMoods = {};
  final Set<String> _selectedSkinTones = {};

  final List<String> _personalColors = ['봄 웜톤', '가을 웜톤', '겨울 쿨톤', '여름쿨톤', '잘 모르겠음'];
  final List<String> _moods = ['청순', '시크', '큐티', '섹시', '차분'];
  final List<String> _skinTones = ['13호 ~ 17호', '21호', '23호', '25호', '27호'];

  Size? get _imageSize {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size;
  }

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() => _isLoggedIn = token != null && token.isNotEmpty);
  }

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

  Future<void> _openProductSearch() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 먼저 선택해주세요.')),
      );
      return;
    }
    final product = await showModalBottomSheet<ProductItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProductSearchSheet(),
    );
    if (product == null) return;
    setState(() {
      _stickers.add(_StickerData(
        xRatio: 0.5,
        yRatio: 0.5,
        brandName: product.brand,
        productName: product.name,
        imagePath: product.imagePath,
      ));
    });
  }

  void _onPanStart(int index) {
    setState(() {
      _draggingIndex = index;
      _tappedStickerIndex = null;
    });
  }

  void _onPanUpdate(int index, DragUpdateDetails details) {
    final size = _imageSize;
    if (size == null) return;
    setState(() {
      final s = _stickers[index];
      s.xRatio = (s.xRatio + details.delta.dx / size.width).clamp(0.0, 1.0);
      s.yRatio = (s.yRatio + details.delta.dy / size.height).clamp(0.0, 1.0);
      _overTrash = s.yRatio > 0.80 && s.xRatio > 0.30 && s.xRatio < 0.70;
    });
  }

  void _onPanEnd(int index) {
    if (_overTrash) {
      setState(() {
        _stickers.removeAt(index);
        _draggingIndex = null;
        _overTrash = false;
      });
    } else {
      setState(() {
        _draggingIndex = null;
        _overTrash = false;
      });
    }
  }

  void _togglePersonalColor(String tag) {
    setState(() {
      if (_selectedPersonalColors.contains(tag)) {
        _selectedPersonalColors.remove(tag);
      } else {
        _selectedPersonalColors
          ..clear()
          ..add(tag);
      }
    });
  }

  void _toggleMood(String tag) {
    setState(() {
      if (_selectedMoods.contains(tag)) {
        _selectedMoods.remove(tag);
      } else if (_selectedMoods.length < 2) {
        _selectedMoods.add(tag);
      }
    });
  }

  void _toggleSkinTone(String tag) {
    setState(() {
      if (_selectedSkinTones.contains(tag)) {
        _selectedSkinTones.remove(tag);
      } else {
        _selectedSkinTones
          ..clear()
          ..add(tag);
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

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    final hasTag = _selectedPersonalColors.isNotEmpty ||
        _selectedMoods.isNotEmpty ||
        _selectedSkinTones.isNotEmpty;

    if (!hasTag) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추구미 태그를 최소 1개 이상 선택해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/post'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      request.fields['title'] = _titleController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['personalColors'] = jsonEncode(
        _selectedPersonalColors.toList(),
      );
      request.fields['moods'] = jsonEncode(_selectedMoods.toList());
      request.fields['skinTones'] = jsonEncode(_selectedSkinTones.toList());
      request.fields['stickers'] = jsonEncode(
        _stickers
            .map(
              (s) => {
                'xRatio': s.xRatio,
                'yRatio': s.yRatio,
                'brandName': s.brandName,
                'productName': s.productName,
              },
            )
            .toList(),
      );

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 201) {
        widget.onPostSuccess?.call();
      } else {
        final body = await response.stream.bytesToString();
        if (!mounted) return;
        final message = jsonDecode(body)['message'] ?? '게시글 등록에 실패했어요.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 연결에 실패했어요.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Widget> _buildProductList() {
    final seen = <String>{};
    final unique = _stickers.where((s) => seen.add(s.productName)).toList();

    if (unique.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '제품 태그하기로 제품을 추가해보세요',
              style: TextStyle(fontSize: 13, color: Color(0xffaaaaaa)),
            ),
          ),
        ),
      ];
    }

    return unique.map((s) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: s.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(s.imagePath!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.face_retouching_natural,
                      color: Color(0xffcccccc),
                      size: 26,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.brandName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.productName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildStickerPins() {
    final size = _imageSize;
    if (size == null || _selectedImage == null) return [];
    const pinSize = 28.0;

    return _stickers.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final isDragging = _draggingIndex == i;

      return Positioned(
        left: s.xRatio * size.width - pinSize / 2,
        top: s.yRatio * size.height - pinSize / 2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _tappedStickerIndex = _tappedStickerIndex == i ? null : i;
          }),
          onPanStart: (_) => _onPanStart(i),
          onPanUpdate: (d) => _onPanUpdate(i, d),
          onPanEnd: (_) => _onPanEnd(i),
          child: AnimatedScale(
            scale: isDragging ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: pinSize,
              height: pinSize,
              decoration: BoxDecoration(
                color: isDragging && _overTrash
                    ? Colors.red
                    : const Color(0xff9c27b0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget? _buildStickerPopup(Size size) {
    final i = _tappedStickerIndex;
    if (i == null || i >= _stickers.length) return null;
    final s = _stickers[i];

    const cardWidth = 200.0;
    const cardEstimatedHeight = 90.0;
    const pinSize = 28.0;

    final stickerX = s.xRatio * size.width;
    final stickerY = s.yRatio * size.height;

    final left = (stickerX - cardWidth / 2).clamp(8.0, size.width - cardWidth - 8);
    final top = s.yRatio < 0.55
        ? (stickerY + pinSize).clamp(8.0, size.height - cardEstimatedHeight - 8)
        : (stickerY - cardEstimatedHeight - 8).clamp(8.0, size.height - cardEstimatedHeight - 8);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: s.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(s.imagePath!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.face_retouching_natural,
                        color: Color(0xffcccccc),
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.brandName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff888888),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.productName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _tappedStickerIndex = null),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xffaaaaaa),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrashZone() {
    return Positioned(
      bottom: 14,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _overTrash
                ? Colors.red.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: _overTrash ? 28 : 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) return const Scaffold(backgroundColor: Colors.white);
    if (_isLoggedIn == false) return const UploadLoginGate();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                padding: EdgeInsets.fromLTRB(18, 22, 18, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사진',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Stack(
                        key: _imageKey,
                        children: [
                          UploadImageBox(
                            selectedImage: _selectedImage,
                            onTap: _pickImage,
                          ),
                          ..._buildStickerPins(),
                          if (_draggingIndex != null) _buildTrashZone(),
                          if (_tappedStickerIndex != null)
                            _buildStickerPopup(_imageSize!) ?? const SizedBox.shrink(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: _openProductSearch,
                          icon: const Icon(Icons.push_pin_outlined, size: 15),
                          label: const Text(
                            '제품 태그하기',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff9c27b0),
                            side: const BorderSide(color: Color(0xff9c27b0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      '제목',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    UploadInputBox(controller: _titleController),

                    const SizedBox(height: 14),

                    const Text(
                      '설명',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    UploadInputBox(
                      controller: _descriptionController,
                      height: 130,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      '추구미 태그',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),

                    const SizedBox(height: 16),

                    TagSection(
                      title: '퍼스널 컬러',
                      hint: '1개만 선택해주세요',
                      tags: _personalColors,
                      selectedTags: _selectedPersonalColors,
                      onTap: _togglePersonalColor,
                    ),

                    const SizedBox(height: 14),

                    TagSection(
                      title: '분위기',
                      hint: '최대 2개 선택',
                      tags: _moods,
                      selectedTags: _selectedMoods,
                      onTap: _toggleMood,
                    ),

                    const SizedBox(height: 14),

                    TagSection(
                      title: '피부 톤',
                      hint: '1개만 선택해주세요',
                      tags: _skinTones,
                      selectedTags: _selectedSkinTones,
                      onTap: _toggleSkinTone,
                    ),

                    const SizedBox(height: 28),

                    UploadMenuRow(
                      icon: Symbols.visibility_lock,
                      title: '공개 대상',
                      value: _publicScope,
                      onTap: _openPublicScopePage,
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      '사용한 제품',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),

                    const SizedBox(height: 14),

                    ..._buildProductList(),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff9c27b0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('게시하기'),
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
