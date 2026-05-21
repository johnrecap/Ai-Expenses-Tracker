import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/app_lock/views/create_pin_screen.dart';
import 'package:expenses_tracker/screens/app_lock/views/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('create PIN screen renders Arabic copy', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppLockCubit(),
        child: localizedTestApp(
          locale: const Locale('ar'),
          home: const CreatePinScreen(),
        ),
      ),
    );

    expect(find.text('Create PIN'), findsNothing);
    expect(find.text('إنشاء PIN'), findsOneWidget);
    expect(find.text('تفعيل قفل التطبيق'), findsOneWidget);
  });

  testWidgets('unlock screen renders Arabic copy', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppLockCubit(),
        child: localizedTestApp(
          locale: const Locale('ar'),
          home: const UnlockScreen(),
        ),
      ),
    );

    expect(find.text('Expense Tracker is locked'), findsNothing);
    expect(find.text('Unlock'), findsNothing);
    expect(find.text('Expense Tracker مقفل'), findsOneWidget);
    expect(find.text('فتح'), findsOneWidget);
  });
}
