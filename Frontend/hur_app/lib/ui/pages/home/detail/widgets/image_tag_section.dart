//  ————————————————————————————————
//  |    이미지 영역(태그 기능)       |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/ui/pages/home/detail/popup/product_tag_popup.dart';

class ImageTagSection extends StatefulWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> stickers;

  const ImageTagSection({
    super.key,
    required this.imageUrl,
    this.stickers = const [],
  });

  @override
  State<ImageTagSection> createState() => _ImageTagSectionState();
}

class _ImageTagSectionState extends State<ImageTagSection> {
  final GlobalKey _stackKey = GlobalKey();
  Size? _containerSize;
  bool _showPins = false;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  void _updateSize() {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      setState(() => _containerSize = box.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _containerSize;

    return SizedBox(
      key: _stackKey,
      width: double.infinity,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _showPins = !_showPins;
              _tappedIndex = null;
            }),
            child: Image.network(
              widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
                }
                return child;
              },
              errorBuilder: (context, error, stackTrace) => AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(color: const Color(0xFFEEEEEE)),
              ),
            ),
          ),

          if (_showPins && size != null)
            ...widget.stickers.asMap().entries.expand((entry) {
              final i = entry.key;
              final s = entry.value;
              final xRatio = double.tryParse(s['x_ratio'].toString()) ?? 0.5;
              final yRatio = double.tryParse(s['y_ratio'].toString()) ?? 0.5;
              final pinLeft = xRatio * size.width - 17;
              final pinTop = yRatio * size.height - 17;

              return [
                Positioned(
                  left: pinLeft,
                  top: pinTop,
                  child: GestureDetector(
                    onTap: () => setState(() =>
                        _tappedIndex = _tappedIndex == i ? null : i),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xff9c27b0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                if (_tappedIndex == i)
                  Positioned(
                    left: (pinLeft + 34 + 185 > size.width)
                        ? pinLeft - 185
                        : pinLeft + 34,
                    top: pinTop - 10,
                    child: ProductTagPopup(
                      brandName: s['brand_name'] ?? '',
                      productName: s['product_name'] ?? '',
                    ),
                  ),
              ];
            }),
        ],
      ),
    );
  }
}
