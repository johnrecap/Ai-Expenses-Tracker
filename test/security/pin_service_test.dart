import 'dart:math';

import 'package:expenses_tracker/security/security.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryAppLockStorage implements AppLockStorage {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

void main() {
  test('correct PIN verifies and wrong PIN fails', () async {
    final storage = MemoryAppLockStorage();
    final service = PinService(storage: storage, random: Random(7));

    await service.setPin('1234');

    expect(await service.hasPin(), isTrue);
    expect(await service.verifyPin('1234'), isTrue);
    expect(await service.verifyPin('4321'), isFalse);
  });

  test('plain PIN is not stored in secure storage values', () async {
    final storage = MemoryAppLockStorage();
    final service = PinService(storage: storage, random: Random(7));

    await service.setPin('9876');

    expect(storage.values.values, isNot(contains('9876')));
    expect(
      storage.values.values.any((value) => value.contains('9876')),
      isFalse,
    );
  });

  test('rejects invalid PIN lengths and non-digit values', () async {
    final service = PinService(
      storage: MemoryAppLockStorage(),
      random: Random(7),
    );

    expect(() => service.setPin('123'), throwsFormatException);
    expect(() => service.setPin('123456789'), throwsFormatException);
    expect(() => service.setPin('12a4'), throwsFormatException);
  });
}
