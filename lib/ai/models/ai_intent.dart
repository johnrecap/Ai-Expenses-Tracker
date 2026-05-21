enum AiIntent {
  addExpense,
  updateExpense,
  deleteExpense,
  searchExpenses,
  summarizeExpenses,
  financialAdvice,
  unknown;

  String get value {
    switch (this) {
      case AiIntent.addExpense:
        return 'add_expense';
      case AiIntent.updateExpense:
        return 'update_expense';
      case AiIntent.deleteExpense:
        return 'delete_expense';
      case AiIntent.searchExpenses:
        return 'search_expenses';
      case AiIntent.summarizeExpenses:
        return 'summarize_expenses';
      case AiIntent.financialAdvice:
        return 'financial_advice';
      case AiIntent.unknown:
        return 'unknown';
    }
  }

  static AiIntent fromJson(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    switch (normalized) {
      case 'add_expense':
      case 'addexpense':
        return AiIntent.addExpense;
      case 'update_expense':
      case 'updateexpense':
        return AiIntent.updateExpense;
      case 'delete_expense':
      case 'deleteexpense':
        return AiIntent.deleteExpense;
      case 'search_expenses':
      case 'searchexpenses':
        return AiIntent.searchExpenses;
      case 'summarize_expenses':
      case 'summarizeexpenses':
        return AiIntent.summarizeExpenses;
      case 'financial_advice':
      case 'financialadvice':
        return AiIntent.financialAdvice;
      default:
        return AiIntent.unknown;
    }
  }

  static AiIntent fromJsonValue(Object? value) => fromJson(value);
}
