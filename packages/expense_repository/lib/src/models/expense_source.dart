enum ExpenseSource {
  manual,
  ai,
  recurring,
  receipt,
}

extension ExpenseSourceX on ExpenseSource {
  String get value {
    switch (this) {
      case ExpenseSource.manual:
        return 'manual';
      case ExpenseSource.ai:
        return 'ai';
      case ExpenseSource.recurring:
        return 'recurring';
      case ExpenseSource.receipt:
        return 'receipt';
    }
  }
}

ExpenseSource expenseSourceFromString(String? value) {
  switch (value) {
    case 'ai':
      return ExpenseSource.ai;
    case 'recurring':
      return ExpenseSource.recurring;
    case 'receipt':
      return ExpenseSource.receipt;
    case 'manual':
    default:
      return ExpenseSource.manual;
  }
}
