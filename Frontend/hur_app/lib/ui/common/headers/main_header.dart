import 'package:flutter/material.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({
    super.key,
    this.title,
    this.titleFontSize = 24.0,
    this.subtitle,
    this.subtitleAbove = false,
    this.leading,
    this.trailing,
    this.bottom,
    this.showDivider = true,
    this.padding = const EdgeInsets.fromLTRB(18, 14, 18, 14),
    this.height,
  });

  final String? title;
  final double titleFontSize;
  final String? subtitle;
  final bool subtitleAbove;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final bool showDivider;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final hasTopRow = leading != null || title != null || trailing != null;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (hasTopRow)
          Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ?leading,
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subtitle != null && subtitleAbove) ...[
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (subtitle != null && !subtitleAbove) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else if (trailing != null)
                  const Spacer(),
                ?trailing,
              ],
            ),
          ),
        ?bottom,
      ],
    );

    return height != null ? SizedBox(height: height, child: column) : column;
  }
}
