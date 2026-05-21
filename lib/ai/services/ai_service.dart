import 'package:expense_repository/expense_repository.dart';

import '../models/ai_response.dart';

class AiContext {
  const AiContext({
    required this.now,
    this.userId,
    this.categories = const [],
    this.categoryAliases = const [],
    this.expenses = const [],
    this.budget,
    this.settings,
    this.defaultCurrency = 'EGP',
    this.defaultPaymentMethod = PaymentMethod.cash,
    this.locale = 'en-US',
  });

  final DateTime now;
  final String? userId;
  final List<Category> categories;
  final List<CategoryAlias> categoryAliases;
  final List<Expense> expenses;
  final Budget? budget;
  final UserSettings? settings;
  final String defaultCurrency;
  final PaymentMethod defaultPaymentMethod;
  final String locale;

  UserSettings get effectiveSettings {
    final providedSettings = settings;
    if (providedSettings != null) return providedSettings;
    return UserSettings.defaults(userId: userId ?? '').copyWith(
      baseCurrency: defaultCurrency,
      supportedCurrencies: [defaultCurrency],
      defaultPaymentMethod: defaultPaymentMethod,
    );
  }
}

abstract class AiService {
  Future<AiResponse> parseExpenseText(String input, AiContext context);
}
