import 'package:flutter/material.dart';

import 'category_icon_registry.dart';

class CategoryIconView extends StatelessWidget {
  const CategoryIconView({
    required this.iconKey,
    required this.backgroundColor,
    this.size = 42,
    this.iconSize,
    this.semanticLabel,
    this.foregroundColor,
    this.borderRadius,
    super.key,
  });

  final String? iconKey;
  final Color backgroundColor;
  final double size;
  final double? iconSize;
  final String? semanticLabel;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final definition = CategoryIconRegistry.resolve(iconKey);
    final foreground = foregroundColor ?? _foregroundFor(backgroundColor);
    return Semantics(
      label: semanticLabel ?? definition.label,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
        alignment: Alignment.center,
        child: Icon(
          definition.icon,
          color: foreground,
          size: iconSize ?? size * 0.5,
        ),
      ),
    );
  }

  Color _foregroundFor(Color background) {
    return background.computeLuminance() > 0.55
        ? const Color(0xFF1F2933)
        : Colors.white;
  }
}
