import 'package:expenses_tracker/categories/category_color_presets.dart';
import 'package:expenses_tracker/categories/category_icon_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves legacy category icon keys', () {
    for (final key in [
      'food',
      'shopping',
      'health',
      'travel',
      'tech',
      'home',
      'entertainment',
      'pet',
    ]) {
      final definition = CategoryIconRegistry.resolve(key);

      expect(definition.key, isNot('other.category'), reason: key);
      expect(definition.label, isNotEmpty);
    }
  });

  test('unknown icon key returns fallback', () {
    final definition = CategoryIconRegistry.resolve('missing-key');

    expect(definition.key, CategoryIconRegistry.fallback.key);
  });

  test('every registered icon has key label group and icon', () {
    final keys = <String>{};
    for (final definition in CategoryIconRegistry.definitions) {
      expect(definition.key, isNotEmpty);
      expect(definition.label, isNotEmpty);
      expect(definition.group, isNotEmpty);
      expect(definition.icon.codePoint, isNonZero);
      expect(keys.add(definition.key), isTrue, reason: definition.key);
    }
  });

  test('registry exposes at least forty choices', () {
    expect(CategoryIconRegistry.definitions.length, greaterThanOrEqualTo(40));
  });

  test('color presets are unique and labeled', () {
    final colors = <int>{};
    for (final preset in CategoryColorPresets.values) {
      expect(preset.key, isNotEmpty);
      expect(preset.label, isNotEmpty);
      expect(colors.add(preset.color.toARGB32()), isTrue);
    }
    expect(CategoryColorPresets.values.length, greaterThanOrEqualTo(16));
  });
}
