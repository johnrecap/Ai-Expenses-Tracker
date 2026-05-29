import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:expenses_tracker/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  Size size = const Size(360, 640),
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Center(
            child: SizedBox(width: size.width, child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FinanceCard renders compact RTL content', (tester) async {
    await tester.pumpWidget(
      _host(
        const FinanceCard(
          leadingAccent: Colors.teal,
          child: Text('بطاقة مالية'),
        ),
        textDirection: TextDirection.rtl,
        size: const Size(320, 640),
      ),
    );

    expect(find.text('بطاقة مالية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MoneyAmountText scales long values without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 140,
          child: MoneyAmountText(
            amount: '123,456,789.99',
            currencyCode: 'EGP',
            secondaryText: '26/05/2026',
          ),
        ),
        textScale: 1.5,
        size: const Size(240, 640),
      ),
    );

    expect(find.text('123,456,789.99 EGP'), findsOneWidget);
    expect(find.text('26/05/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TransactionRow supports Arabic labels and status chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: TransactionRow(
            title: 'مواصلات طويلة جدا لاختبار العرض',
            subtitle: 'رحلة صباحية من البيت إلى العمل',
            amount: '300',
            currencyCode: 'EGP',
            dateText: '26/05/2026',
            status: Chip(label: Text('Pending')),
          ),
        ),
        textDirection: TextDirection.rtl,
        textScale: 1.2,
        size: const Size(340, 640),
      ),
    );

    expect(find.text('مواصلات طويلة جدا لاختبار العرض'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppStatusBanner action is tappable', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _host(
        AppStatusBanner(
          message: 'Expense is waiting to sync',
          tone: AppStatusTone.warning,
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppTextField keeps Arabic label readable at high scale', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'قهوة 50 جنيه');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        AppTextField(
          controller: controller,
          label: 'اكتب المصروف',
          hint: 'مثال: قهوة 50 جنيه',
          prefixIcon: Icons.auto_awesome,
        ),
        textDirection: TextDirection.rtl,
        textScale: 1.4,
        size: const Size(320, 640),
      ),
    );

    expect(find.text('اكتب المصروف'), findsOneWidget);
    expect(find.text('قهوة 50 جنيه'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
