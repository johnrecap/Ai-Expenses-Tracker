import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds user-scoped Firestore paths', () {
    expect(
      FirebaseExpenseRepo.expensesPathFor('user-a'),
      'users/user-a/expenses',
    );
    expect(
      FirebaseCategoryRepository.categoriesPathFor('user-a'),
      'users/user-a/categories',
    );
  });

  test('rejects empty user ids', () {
    expect(
      () => FirebaseExpenseRepo(userId: ''),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => FirebaseCategoryRepository(userId: ''),
      throwsA(isA<ArgumentError>()),
    );
  });
}
