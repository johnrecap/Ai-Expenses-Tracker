import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/export/export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV export writes headers and escapes values', () async {
    const exporter = CsvExportService();
    final result = await exporter.exportExpenses(
      expenses: [
        _expense(
          id: '1',
          description: 'Lunch, "special"\nwith team',
          categoryName: 'Food',
        ),
      ],
      request: ExportRequest(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        format: ExportFormat.csv,
      ),
    );

    final csv = utf8.decode(result.bytes);

    expect(
      csv,
      contains(
        'date,amount,currency,category,paymentMethod,description,merchant,tags',
      ),
    );
    expect(csv, contains('120.75'));
    expect(csv, contains('"Lunch, ""special""\nwith team"'));
    expect(result.fileName, 'expenses_2026-05-01_2026-05-31.csv');
    expect(result.mimeType, 'text/csv');
  });

  test('export filters rows by date category payment method and currency',
      () async {
    const exporter = CsvExportService();
    final result = await exporter.exportExpenses(
      expenses: [
        _expense(id: 'food-cash', categoryName: 'Food'),
        _expense(
          id: 'food-visa',
          categoryName: 'Food',
          paymentMethod: PaymentMethod.visa,
        ),
        _expense(id: 'transport-cash', categoryName: 'Transport'),
        _expense(
          id: 'old-food',
          categoryName: 'Food',
          date: DateTime(2026, 4, 30),
        ),
        _expense(id: 'usd-food', categoryName: 'Food', currency: 'USD'),
      ],
      request: ExportRequest(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        format: ExportFormat.csv,
        categoryIds: ['food'],
        paymentMethods: const [PaymentMethod.cash],
        currency: 'EGP',
      ),
    );

    final csv = utf8.decode(result.bytes);

    expect(csv, contains('food-cash'));
    expect(csv, isNot(contains('food-visa')));
    expect(csv, isNot(contains('transport-cash')));
    expect(csv, isNot(contains('old-food')));
    expect(csv, isNot(contains('usd-food')));
  });

  test('export request rejects invalid date range', () async {
    const exporter = CsvExportService();

    expect(
      () => exporter.exportExpenses(
        expenses: const [],
        request: ExportRequest(
          startDate: DateTime(2026, 5, 31),
          endDate: DateTime(2026, 5, 1),
          format: ExportFormat.csv,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('CSV export appends conversion metadata when settings are available',
      () async {
    const exporter = CsvExportService();
    final result = await exporter.exportExpenses(
      expenses: [
        _expense(id: 'egp-food', amount: 100, currency: 'EGP'),
        _expense(id: 'usd-food', amount: 10, currency: 'USD'),
        _expense(id: 'eur-food', amount: 5, currency: 'EUR'),
      ],
      request: ExportRequest(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        format: ExportFormat.csv,
        settings: UserSettings.defaults(userId: 'user-1').copyWith(
          baseCurrency: 'EGP',
          supportedCurrencies: const ['EGP', 'USD', 'EUR'],
          conversionRates: const {'USD': 50},
          exchangeRatesUpdatedAt: DateTime(2026, 5, 17),
        ),
      ),
    );

    final csv = utf8.decode(result.bytes);

    expect(
      csv,
      contains(
        'date,amount,currency,category,paymentMethod,description,merchant,tags,convertedAmount,convertedCurrency,conversionRate,conversionRateDate,conversionStatus',
      ),
    );
    expect(csv, contains('egp-food'));
    expect(csv, contains('100,EGP,1,2026-05-17,original'));
    expect(csv, contains('500,EGP,50,2026-05-17,converted'));
    expect(csv, contains('EUR'));
    expect(csv, contains('missingRate'));
  });
}

Expense _expense({
  required String id,
  String categoryName = 'Food',
  String description = '',
  double amount = 120.75,
  DateTime? date,
  PaymentMethod paymentMethod = PaymentMethod.cash,
  String currency = 'EGP',
  String? merchant,
  List<String> tags = const [],
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 0xFFFFFFFF,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date ?? DateTime(2026, 5, 15),
    amount: amount,
    description: description.isEmpty ? id : description,
    merchant: merchant,
    tags: tags,
    paymentMethod: paymentMethod,
    currency: currency,
  );
}
