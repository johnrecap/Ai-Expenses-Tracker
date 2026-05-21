import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/auth/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppView extends StatelessWidget {
  final AuthRepository? authRepository;

  const MyAppView({
    super.key,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => authRepository ?? FirebaseAuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(create: (_) => AppLanguageCubit()),
        ],
        child: BlocBuilder<AppLanguageCubit, LanguagePreference>(
          builder: (context, languagePreference) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: languagePreference.forcedLocale,
              onGenerateTitle: (context) => context.l10n.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(
                colorScheme: ColorScheme.light(
                  surface: Colors.grey.shade100,
                  onSurface: Colors.black,
                  primary: const Color(0xFF00B2E7),
                  secondary: const Color(0xFFE064F7),
                  tertiary: const Color(0xFFFF8D6C),
                  outline: Colors.grey[500],
                ),
              ),
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}
