import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  test('fake settings repository saves app-local display name', () async {
    final repository = FakeSettingsRepository(
      UserSettings.defaults(userId: 'user-1'),
    );

    await repository.updateAppDisplayName('  Local Person  ');

    expect(repository.settings.appDisplayName, 'Local Person');
  });

  test('fake settings repository clears blank app-local display name',
      () async {
    final repository = FakeSettingsRepository(
      UserSettings.defaults(userId: 'user-1').copyWith(
        appDisplayName: 'Local Person',
      ),
    );

    await repository.updateAppDisplayName('  ');

    expect(repository.settings.appDisplayName, isNull);
  });
}
