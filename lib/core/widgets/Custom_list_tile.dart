import 'package:flutter/material.dart';
import '../../config/app_cards.dart';
import '../../config/style.dart';

class CustomListTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final VoidCallback? onFirstButtonPressed;
  final VoidCallback? onSecondButtonPressed;
  final double? widthFactor;

  const CustomListTile({
    Key? key,
    this.item = const {},
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.onFirstButtonPressed,
    this.onSecondButtonPressed,
    this.widthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: screenWidth * (widthFactor ?? 0.9),
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: TileConfig.backgroundColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: TileConfig.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || leading != null || trailing != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: title ??
                        Text(
                          item['title'] ?? '',
                          style: fontStyles.headingStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            if (subtitle != null) ...[
              if (title != null || leading != null || trailing != null)
                const SizedBox(height: 8),
              subtitle!,
            ],
          ],
        ),
      ),
    );
  }
}
