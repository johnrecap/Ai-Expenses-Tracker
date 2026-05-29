import 'package:expense_repository/expense_repository.dart';

enum ExpenseEditValidationError {
  invalidAmount,
  missingCategory,
  missingCurrency,
}

class ExpenseEditDraft {
  const ExpenseEditDraft({
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.merchant,
    required this.tags,
    required this.paymentMethod,
    required this.currency,
  });

  factory ExpenseEditDraft.fromExpense(Expense expense) {
    return ExpenseEditDraft(
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      description: expense.description,
      merchant: expense.merchant,
      tags: expense.tags,
      paymentMethod: expense.paymentMethod,
      currency: expense.currency,
    );
  }

  final double amount;
  final Category category;
  final DateTime date;
  final String description;
  final String? merchant;
  final List<String> tags;
  final PaymentMethod paymentMethod;
  final String currency;

  bool get hasValidAmount => amount > 0;

  ExpenseEditDraft adjustAmount(double delta) {
    return copyWith(amount: amount + delta);
  }

  List<ExpenseEditValidationError> validate() {
    return [
      if (!hasValidAmount) ExpenseEditValidationError.invalidAmount,
      if (category.categoryId.trim().isEmpty)
        ExpenseEditValidationError.missingCategory,
      if (currency.trim().isEmpty) ExpenseEditValidationError.missingCurrency,
    ];
  }

  bool moneyInputsChanged(Expense previous) {
    return previous.amount != amount ||
        previous.currency.trim().toUpperCase() !=
            currency.trim().toUpperCase() ||
        DateTime(previous.date.year, previous.date.month, previous.date.day) !=
            DateTime(date.year, date.month, date.day);
  }

  Expense toExpense(Expense previous) {
    return Expense(
      expenseId: previous.expenseId,
      userId: previous.userId,
      category: category,
      date: date,
      amount: amount,
      description: description.trim(),
      merchant: merchant,
      tags: tags,
      paymentMethod: paymentMethod,
      currency: currency.trim().toUpperCase(),
      createdAt: previous.createdAt,
      updatedAt: DateTime.now(),
      source: previous.source,
      walletAccountId: previous.walletAccountId,
      walletAccountName: previous.walletAccountName,
      recurringExpenseId: previous.recurringExpenseId,
      aiActionId: previous.aiActionId,
      moneySnapshot: previous.moneySnapshot,
      syncStatus: previous.syncStatus,
      syncStatusReason: previous.syncStatusReason,
    );
  }

  ExpenseEditDraft copyWith({
    double? amount,
    Category? category,
    DateTime? date,
    String? description,
    String? merchant,
    List<String>? tags,
    PaymentMethod? paymentMethod,
    String? currency,
  }) {
    return ExpenseEditDraft(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      tags: tags ?? this.tags,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
    );
  }
}
