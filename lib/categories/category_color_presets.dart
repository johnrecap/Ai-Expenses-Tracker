import 'package:flutter/material.dart';

class CategoryColorPreset {
  const CategoryColorPreset({
    required this.key,
    required this.label,
    required this.color,
    this.foreground = Colors.white,
  });

  final String key;
  final String label;
  final Color color;
  final Color foreground;
}

class CategoryColorPresets {
  const CategoryColorPresets._();

  static const values = <CategoryColorPreset>[
    CategoryColorPreset(key: 'coral', label: 'Coral', color: Color(0xFFFF7043)),
    CategoryColorPreset(key: 'amber', label: 'Amber', color: Color(0xFFFFB300)),
    CategoryColorPreset(key: 'mint', label: 'Mint', color: Color(0xFF26A69A)),
    CategoryColorPreset(key: 'green', label: 'Green', color: Color(0xFF43A047)),
    CategoryColorPreset(key: 'blue', label: 'Blue', color: Color(0xFF42A5F5)),
    CategoryColorPreset(key: 'navy', label: 'Navy', color: Color(0xFF3949AB)),
    CategoryColorPreset(
        key: 'violet', label: 'Violet', color: Color(0xFF7E57C2)),
    CategoryColorPreset(key: 'pink', label: 'Pink', color: Color(0xFFEC407A)),
    CategoryColorPreset(key: 'rose', label: 'Rose', color: Color(0xFFD81B60)),
    CategoryColorPreset(key: 'brown', label: 'Brown', color: Color(0xFF8D6E63)),
    CategoryColorPreset(key: 'slate', label: 'Slate', color: Color(0xFF607D8B)),
    CategoryColorPreset(key: 'steel', label: 'Steel', color: Color(0xFF546E7A)),
    CategoryColorPreset(key: 'teal', label: 'Teal', color: Color(0xFF00897B)),
    CategoryColorPreset(key: 'lime', label: 'Lime', color: Color(0xFF7CB342)),
    CategoryColorPreset(
        key: 'orange', label: 'Orange', color: Color(0xFFFB8C00)),
    CategoryColorPreset(key: 'red', label: 'Red', color: Color(0xFFE53935)),
  ];

  static CategoryColorPreset? byColor(Color color) {
    for (final preset in values) {
      if (preset.color.toARGB32() == color.toARGB32()) return preset;
    }
    return null;
  }
}
