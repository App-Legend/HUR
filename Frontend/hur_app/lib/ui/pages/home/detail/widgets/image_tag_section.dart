import 'package:flutter/material.dart';
import 'package:hur_app/ui/pages/home/detail/popup/product_tag_popup.dart';

class ImageTagSection extends StatefulWidget {
  final String imagePath;

  const ImageTagSection({super.key, required this.imagePath});

  @override
  State<ImageTagSection> createState() => _ImageTagSectionState();
}

class _ImageTagSectionState extends State<ImageTagSection> {
  bool showProductIcons = false;
  bool showProductPopup = false;

  void _toggleProductIcons() {
    setState(() {
      showProductIcons = !showProductIcons;
      showProductPopup = false;
    });
  }

  void _toggleProductPopup() {
    setState(() {
      showProductPopup = !showProductPopup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _toggleProductIcons,
            child: Image.asset(
              widget.imagePath,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          _ProductLocationIcon(
            left: 210,
            top: 145,
            visible: showProductIcons,
            onTap: _toggleProductPopup,
          ),

          _ProductLocationIcon(
            left: 145,
            top: 215,
            visible: showProductIcons,
            onTap: _toggleProductPopup,
          ),

          if (showProductPopup)
            const Positioned(
              left: 170,
              top: 250,
              child: ProductTagPopup(
                imagePath: 'assets/images/ranking/detail1.jpg',
                brandName: '립 포션',
                productName: '카라멜 글레이즈',
                price: '18,900원~',
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductLocationIcon extends StatelessWidget {
  final double left;
  final double top;
  final bool visible;
  final VoidCallback onTap;

  const _ProductLocationIcon({
    required this.left,
    required this.top,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 34,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
