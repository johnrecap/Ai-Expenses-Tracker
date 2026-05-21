import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/settings/views/settings_screen.dart';
import 'package:expenses_tracker/screens/settings/widgets/support_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') return null;
      return null;
    });
  });

  testWidgets('renders currency and payment defaults', (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    expect(find.text('App language'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Currency');
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Base currency'), findsOneWidget);
    expect(find.text('Supported currencies'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Payment');
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Cash'), findsWidgets);

    await fixture.dispose(tester);
  });

  testWidgets('renders profile display name with account ID secondary',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Account/Profile'), findsOneWidget);
    expect(find.text('Movie Test'), findsOneWidget);
    expect(find.text('movie@example.com'), findsOneWidget);
    expect(find.text('Account ID'), findsOneWidget);
    expect(find.text('user-1'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('profile identity falls back to email', (tester) async {
    final fixture = _SettingsFixture(
      user: AppUser(
        userId: 'email-user',
        email: 'fallback@example.com',
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5, 1),
      ),
    );
    await fixture.pump(tester);

    expect(find.text('fallback@example.com'), findsOneWidget);
    expect(find.text('email-user'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('profile identity falls back to friendly user label',
      (tester) async {
    final fixture = _SettingsFixture(
      user: AppUser(
        userId: 'uid-only',
        email: null,
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5, 1),
      ),
    );
    await fixture.pump(tester);

    expect(find.text('User'), findsOneWidget);
    expect(find.text('uid-only'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('renders notification and app protection controls',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await _scrollTextIntoView(tester, 'Notifications');
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Budget alerts'), findsOneWidget);
    expect(find.text('Daily check-in'), findsOneWidget);

    await _scrollTextIntoView(tester, 'App Protection');
    expect(find.text('App Protection'), findsOneWidget);
    expect(find.text('PIN lock'), findsOneWidget);
    expect(find.text('Biometric unlock'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('renders AI monetization privacy and support sections',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await _scrollTextIntoView(tester, 'AI Usage');
    expect(find.text('AI Usage'), findsOneWidget);
    expect(find.text('Text parsing'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Free plan');
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Remove ads'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Privacy');
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Data ownership'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Support');
    expect(find.text('Support'), findsOneWidget);
    expect(
      find.text('Send feedback without attaching expense data.'),
      findsOneWidget,
    );

    await fixture.dispose(tester);
  });

  testWidgets(
      'bottom scroll ends at support content without a large blank area',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await _scrollTextIntoView(
      tester,
      'Send feedback without attaching expense data.',
    );

    final lastVisibleText =
        find.text('Send feedback without attaching expense data.');
    expect(lastVisibleText, findsOneWidget);
    final bottom = tester.getBottomLeft(lastVisibleText).dy;
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(bottom, greaterThan(viewportHeight - 150));
    expect(bottom, lessThan(viewportHeight));

    await fixture.dispose(tester);
  });

  testWidgets('Arabic bottom scroll ends at support section without blank area',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();
    await _scrollTextIntoView(tester, 'الدعم');

    final supportSection = find.byType(SupportSettingsSection);
    expect(supportSection, findsOneWidget);
    final bottom = tester.getBottomLeft(supportSection).dy;
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(bottom, greaterThan(viewportHeight - 180));
    expect(bottom, lessThanOrEqualTo(viewportHeight));

    await fixture.dispose(tester);
  });

  testWidgets('settings route tolerates missing optional route providers',
      (tester) async {
    final settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(
        userId: 'route-user',
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
        updatedAt: DateTime(2026, 5, 1),
      ),
    );

    await tester.pumpWidget(
      RepositoryProvider<SettingsRepository>.value(
        value: settingsRepository,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                child: const Text('Open settings'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Settings'), findsOneWidget);
    await _scrollTextIntoView(tester, 'Notifications');
    await _scrollTextIntoView(tester, 'Support');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('language switch rebuilds visible Settings labels immediately',
      (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    expect(find.text('App language'), findsOneWidget);
    await tester.tap(find.text('Arabic'));
    await tester.pump();

    expect(fixture.appLanguageCubit.state, LanguagePreference.arabic);
    expect(find.text('لغة التطبيق'), findsOneWidget);

    await _scrollTextIntoView(tester, 'الإشعارات');
    expect(find.text('الإشعارات'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('settings load failure shows retry without stale controls',
      (tester) async {
    final fixture = _SettingsFixture(failSettings: true);
    await fixture.pump(tester);

    expect(find.text('Settings could not be loaded.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Base currency'), findsNothing);

    await fixture.dispose(tester);
  });

  testWidgets('replay tour action starts the guided tour', (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await _scrollTextIntoView(tester, 'Replay Tour');
    await tester.tap(find.text('Replay Tour'));
    await tester.pump();

    expect(fixture.guidedTourCubit.state.isActive, isTrue);
    expect(
      fixture.guidedTourCubit.state.activeStep?.stepId,
      GuidedTourStepIds.aiAssistant,
    );

    await fixture.dispose(tester);
  });

  testWidgets('account profile validates blank display name', (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await tester.tap(find.text('Account/Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Enter a display name.'), findsOneWidget);
    expect(fixture.accountProfileService.savedDisplayName, isNull);

    await fixture.dispose(tester);
  });

  testWidgets('account profile saves app-local display name', (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    await tester.tap(find.text('Account/Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated Name');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(fixture.accountProfileService.savedDisplayName, 'Updated Name');
    expect(find.text('Updated Name'), findsOneWidget);
    expect(find.text('Display name updated.'), findsOneWidget);

    await fixture.dispose(tester);
  });

  testWidgets('copy account ID shows feedback', (tester) async {
    final fixture = _SettingsFixture();
    await fixture.pump(tester);

    expect(find.byTooltip('Copy account ID'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Account ID copied.'), findsOneWidget);

    await fixture.dispose(tester);
  });
}

Future<void> _scrollTextIntoView(
  WidgetTester tester,
  String text, {
  int maxAttempts = 12,
}) async {
  final finder = find.text(text);
  for (var attempt = 0; attempt < maxAttempts; attempt += 1) {
    if (tester.any(finder)) return;
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Could not find "$text" after scrolling Settings.');
}

class _SettingsFixture {
  _SettingsFixture({
    bool failSettings = false,
    AppUser? user,
  }) {
    this.user = user ??
        AppUser(
          userId: 'user-1',
          email: 'movie@example.com',
          displayName: 'Movie Test',
          photoUrl: null,
          createdAt: DateTime(2026, 5, 1),
        );
    settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(
        userId: this.user.userId,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
        updatedAt: DateTime(2026, 5, 1),
      ),
    )..fail = failSettings;
    guidedTourCubit = GuidedTourCubit(settingsRepository: settingsRepository);
    monetizationCubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.allowed()),
      adService: FakeAdService(),
    );
    appLockCubit = AppLockCubit(appLockService: fakeAppLockService());
    appLanguageCubit = AppLanguageCubit();
    authRepository = FakeAuthRepository(this.user);
    authBloc = AuthBloc(authRepository)..add(AuthUserChanged(this.user));
    accountProfileService = _SettingsAccountProfileService();
  }

  late final AppUser user;
  late final FakeSettingsRepository settingsRepository;
  late final FakeAuthRepository authRepository;
  late final _SettingsAccountProfileService accountProfileService;
  late final GuidedTourCubit guidedTourCubit;
  late final MonetizationCubit monetizationCubit;
  late final AppLockCubit appLockCubit;
  late final AuthBloc authBloc;
  late final AppLanguageCubit appLanguageCubit;

  Future<void> pump(WidgetTester tester) async {
    await monetizationCubit.load();
    await appLockCubit.initialize();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SettingsRepository>.value(
            value: settingsRepository,
          ),
          RepositoryProvider<ObservabilityService>.value(
            value: const NoopObservabilityService(),
          ),
          RepositoryProvider<AuthRepository>.value(
            value: authRepository,
          ),
          RepositoryProvider<AccountProfileService>.value(
            value: accountProfileService,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
            BlocProvider<AppLockCubit>.value(value: appLockCubit),
            BlocProvider<GuidedTourCubit>.value(value: guidedTourCubit),
            BlocProvider<AppLanguageCubit>.value(value: appLanguageCubit),
          ],
          child: BlocBuilder<AppLanguageCubit, LanguagePreference>(
            builder: (context, languagePreference) {
              return MaterialApp(
                locale: languagePreference.forcedLocale ?? const Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SettingsScreen(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await guidedTourCubit.close();
    await monetizationCubit.close();
    await appLockCubit.close();
    await appLanguageCubit.close();
    await authRepository.close();
  }
}

class _SettingsAccountProfileService implements AccountProfileService {
  String? savedDisplayName;

  @override
  Future<void> deleteAuthAccount(AppUser user) async {}

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {}

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    return const AccountProfileCapabilities(
      providerType: AccountProviderType.emailPassword,
      canSendPasswordReset: true,
      canUpdateEmail: true,
    );
  }

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => savedDisplayName;

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {}

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {}

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    savedDisplayName = displayName;
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {}

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {}

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) {
    return Stream.value(savedDisplayName);
  }
}
