import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/product_item_container.dart';
import 'package:material_symbols_icons/symbols.dart';

class StickerTag {
  double xRatio;
  double yRatio;
  StickerTag({required this.xRatio, required this.yRatio});
}

class ProductTagPage extends StatefulWidget {
  final File? selectedImage;

  const ProductTagPage({super.key, required this.selectedImage});

  @override
  State<ProductTagPage> createState() => _ProductTagPageState();
}

class _ProductTagPageState extends State<ProductTagPage> {
  final GlobalKey _imageKey = GlobalKey();
  final List<StickerTag> _stickers = [];

  int? _draggingIndex;
  bool _overTrash = false;

  Size? get _imageSize {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size;
  }

  void _addSticker() {
    if (widget.selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진을 먼저 선택해주세요.')));
      return;
    }
    setState(() {
      _stickers.add(StickerTag(xRatio: 0.5, yRatio: 0.5));
    });
  }

  void _onPanStart(int index) {
    setState(() => _draggingIndex = index);
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

  void _openAddProductPage() {
    // TODO: 화장품 추가 화면 연결
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
            _buildHeader(context),
            Container(height: 1, color: const Color(0xffdddddd)),
            _buildImageArea(),
            _buildAddTagButton(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.chevron_left,
                size: 34,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Text(
              '화장품 태그',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  Navigator.pop(context, List<StickerTag>.from(_stickers)),
              child: const Text(
                '완료',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff9c27b0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Stack(
        children: [
          Container(
            key: _imageKey,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffd9d9d9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: widget.selectedImage == null
                ? const SizedBox(height: 220)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      widget.selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          ..._buildStickerPins(),
          if (_draggingIndex != null) _buildTrashZone(),
        ],
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

  List<Widget> _buildStickerPins() {
    final size = _imageSize;
    if (size == null) return [];
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

  Widget _buildAddTagButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SizedBox(
        width: double.infinity,
        height: 38,
        child: OutlinedButton.icon(
          onPressed: _addSticker,
          icon: const Icon(Icons.push_pin_outlined, size: 16),
          label: const Text('태그 추가', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xff9c27b0),
            side: const BorderSide(color: Color(0xff9c27b0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: _openAddProductPage,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xffd9d9d9),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '화장품 추가',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '등록된 화장품',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          ProductItemContainer(
            imagePath: 'assets/images/ranking/rank1.png',
            brandName: '얼터너티브스테레오',
            productName: '립 포션 카라멜 글레이즈',
            price: '',
            trailingIcon: Symbols.more_horiz,
            onOpenTap: _openProductDetail,
          ),

          const SizedBox(height: 12),

          ProductItemContainer(
            imagePath: 'assets/images/ranking/ranking5.jpg',
            brandName: '퓌',
            productName: '로즈 옵세션 스테이핏 틴트',
            price: '',
            trailingIcon: Symbols.more_horiz,
            onOpenTap: _openProductDetail,
          ),

          const SizedBox(height: 12),

          ProductItemContainer(
            imagePath: 'assets/images/ranking/ranking7.jpg',
            brandName: '헤라',
            productName: '센슈얼 누드 글로스',
            price: '',
            trailingIcon: Symbols.more_horiz,
            onOpenTap: _openProductDetail,
          ),
        ],
      ),
    );
  }
}
