import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes previewed action logs and parses final statuses', () {
    final log = AiActionLog(
      actionId: 'action-1',
      userId: 'user-1',
      rawInput: 'احذف آخر مصروف',
      parsedResponse: const {'intent': 'delete_expense'},
      intent: 'delete_expense',
      confidence: 0.91,
      status: AiActionLogStatus.previewed,
      createdAt: DateTime(2026, 5, 15),
    );

    final document = log.toEntity().toDocument();

    expect(document['status'], 'previewed');
    expect(document['rawInput'], 'احذف آخر مصروف');

    final parsed = AiActionLog.fromEntity(
      AiActionLogEntity.fromDocument({
        ...document,
        'status': 'confirmed',
        'confirmedAt': DateTime(2026, 5, 15, 12),
        'targetExpenseId': 'expense-1',
      }),
    );

    expect(parsed.status, AiActionLogStatus.confirmed);
    expect(parsed.targetExpenseId, 'expense-1');
    expect(parsed.confirmedAt, DateTime(2026, 5, 15, 12));
  });

  test('exposes user-scoped Firestore path for AI actions', () {
    expect(
      FirebaseAiActionLogRepository.aiActionsPathFor('user-a'),
      'users/user-a/ai_actions',
    );
  });
}
