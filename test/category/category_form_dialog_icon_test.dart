import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_color_presets.dart';
import 'package:expenses_tracker/screens/categories/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('saves a modern category icon key from the picker',
      (tester) async {
    Category? savedCategory;

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  savedCategory = await showDialog<Category>(
                    context: context,
                    builder: (_) => const CategoryFormDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Coffee');
    await tester.tap(find.widgetWithText(TextFormField, 'Category'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Search icons'), 'coffee');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Icon Coffee'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Color Mint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedCategory, isNotNull);
    expect(savedCategory!.name, 'Coffee');
    expect(savedCategory!.icon, 'food.coffee');
    expect(
      savedCategory!.color,
      CategoryColorPresets.values
          .firstWhere((preset) => preset.key == 'mint')
          .color
          .toARGB32(),
    );
  });

  testWidgets('maps legacy category icon keys when editing', (tester) async {
    final legacyCategory = Category(
      categoryId: 'legacy-food',
      name: 'Food',
      totalExpenses: 0,
      icon: 'food',
      color: CategoryColorPresets.values.first.color.toARGB32(),
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: CategoryFormDialog(initialCategory: legacyCategory),
        ),
      ),
    );

    expect(find.text('Dining'), findsOneWidget);
  });
}
