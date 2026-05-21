import 'package:expenses_tracker/app_view.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final AuthRepository? authRepository;

  const MyApp({
    super.key,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MyAppView(authRepository: authRepository);
  }
}
