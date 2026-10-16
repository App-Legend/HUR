import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({
    super.key,
    this.title,
    this.titleFontSize = 24.0,
    this.subtitle,
    this.subtitleFontSize = 14.0,
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
  final double subtitleFontSize;
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
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: HurColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: HurColors.text,
                          ),
                        ),
                        if (subtitle != null && !subtitleAbove) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: HurColors.muted,
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
