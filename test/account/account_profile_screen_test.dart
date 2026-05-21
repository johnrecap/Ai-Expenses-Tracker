import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') return null;
      return null;
    });
  });

  testWidgets('renders Google account details without password actions',
      (tester) async {
    final service = _WidgetAccountProfileService(
      localDisplayName: 'Local Name',
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.google,
      ),
    );

    await tester.pumpWidget(_app(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Account/Profile'), findsOneWidget);
    expect(find.text('Local Name'), findsOneWidget);
    expect(find.text('google@example.com'), findsWidgets);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Account ID'), findsOneWidget);
    expect(find.text('google-user'), findsOneWidget);
    expect(
      find.text('This action is unavailable for the current sign-in provider.'),
      findsWidgets,
    );
  });

  testWidgets('edits app-local display name and refreshes screen',
      (tester) async {
    final service = _WidgetAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canSendPasswordReset: true,
        canUpdateEmail: true,
      ),
    );

    await tester.pumpWidget(_app(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Edit profile name'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Local Email Name');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.savedDisplayName, 'Local Email Name');
    expect(find.text('Local Email Name'), findsOneWidget);
    expect(find.text('Display name updated.'), findsOneWidget);
  });

  testWidgets('requires explicit confirmation before delete call',
      (tester) async {
    final service = _WidgetAccountProfileService();

    await tester.pumpWidget(_app(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Delete account'));
    await tester.pump();

    expect(
      find.text('I understand this deletion cannot be undone.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete account'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.deletionCalls, ['data:google-user', 'auth:google-user']);
  });

  testWidgets('shows password reauth prompt before retrying email update',
      (tester) async {
    final service = _WidgetAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canSendPasswordReset: true,
        canUpdateEmail: true,
      ),
    )..emailUpdateError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );

    await tester.pumpWidget(_app(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Update email'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'new@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Sign in again'), findsOneWidget);

    service.emailUpdateError = null;
    await tester.enterText(find.byType(TextField), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.reauthenticatedPasswords, ['secret']);
    expect(service.updatedEmails, ['new@example.com', 'new@example.com']);
  });
}

Widget _app({required AccountProfileService service}) {
  final user = AppUser(
    userId: 'google-user',
    email: 'google@example.com',
    displayName: 'Google Name',
    photoUrl: null,
    createdAt: DateTime(2026, 5, 19),
  );
  return RepositoryProvider<AccountProfileService>.value(
    value: service,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountProfileScreen(user: user),
    ),
  );
}

class _WidgetAccountProfileService implements AccountProfileService {
  _WidgetAccountProfileService({
    this.localDisplayName,
    this.capabilities = const AccountProfileCapabilities(
      providerType: AccountProviderType.emailPassword,
      canSendPasswordReset: true,
      canUpdateEmail: true,
    ),
  });

  String? localDisplayName;
  String? savedDisplayName;
  final AccountProfileCapabilities capabilities;
  final deletionCalls = <String>[];
  final updatedEmails = <String>[];
  final reauthenticatedPasswords = <String>[];
  int googleReauthCalls = 0;
  AccountActionException? emailUpdateError;

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    deletionCalls.add('auth:${user.userId}');
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    deletionCalls.add('data:${user.userId}');
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    return capabilities;
  }

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => localDisplayName;

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {
    reauthenticatedPasswords.add(password);
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {
    googleReauthCalls += 1;
  }

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    savedDisplayName = displayName;
    localDisplayName = displayName;
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {}

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {
    updatedEmails.add(newEmail);
    final error = emailUpdateError;
    if (error != null) throw error;
  }

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) {
    return Stream.value(localDisplayName);
  }
}
