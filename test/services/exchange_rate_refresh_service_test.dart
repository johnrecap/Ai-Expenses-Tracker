import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_refresh_service.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  test('refreshes stale supported currency rates and saves timestamp',
      () async {
    final now = DateTime(2026, 5, 19, 9);
    final settings = _settings(
      userId: 'user-refresh',
      updatedAt: DateTime(2026, 5, 18),
    );
    final repository = FakeSettingsRepository(settings);
    final provider = _FakeExchangeRateService({'USD': 50.5, 'EUR': 55.25});
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: provider,
      now: () => now,
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(provider.calls, 1);
    expect(provider.requestedQuotes.single, ['EUR', 'USD']);
    expect(refreshed.conversionRates, {'USD': 50.5, 'EUR': 55.25});
    expect(refreshed.exchangeRatesUpdatedAt, now);
    expect(repository.settings.conversionRates, {'USD': 50.5, 'EUR': 55.25});
    expect(repository.settings.exchangeRatesUpdatedAt, now);
  });

  test('does not refresh again on the same local day', () async {
    final now = DateTime(2026, 5, 19, 12);
    final settings = _settings(
      userId: 'user-fresh',
      supportedCurrencies: const ['EGP', 'USD'],
      conversionRates: const {'USD': 51},
      exchangeRatesUpdatedAt: DateTime(2026, 5, 19, 7),
    );
    final repository = FakeSettingsRepository(settings);
    final provider = _FakeExchangeRateService({'USD': 52});
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: provider,
      now: () => now,
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(provider.calls, 0);
    expect(refreshed.conversionRates, {'USD': 51});
    expect(repository.settings.conversionRates, {'USD': 51});
  });

  test('refreshes same-day rates when a supported target is missing', () async {
    final now = DateTime(2026, 5, 19, 12);
    final settings = _settings(
      userId: 'user-missing-target',
      supportedCurrencies: const ['EGP', 'USD', 'EUR'],
      conversionRates: const {'USD': 51},
      exchangeRatesUpdatedAt: DateTime(2026, 5, 19, 7),
    );
    final repository = FakeSettingsRepository(settings);
    final provider = _FakeExchangeRateService({'USD': 52, 'EUR': 56});
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: provider,
      now: () => now,
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(provider.calls, 1);
    expect(provider.requestedQuotes.single, ['EUR', 'USD']);
    expect(refreshed.conversionRates, {'USD': 52, 'EUR': 56});
    expect(refreshed.exchangeRatesUpdatedAt, now);
  });

  test('refreshes same-day rates when a supported target rate is invalid',
      () async {
    final now = DateTime(2026, 5, 19, 12);
    final settings = _settings(
      userId: 'user-invalid-target',
      supportedCurrencies: const ['EGP', 'USD', 'EUR'],
      conversionRates: const {'USD': 51, 'EUR': -1},
      exchangeRatesUpdatedAt: DateTime(2026, 5, 19, 7),
    );
    final repository = FakeSettingsRepository(settings);
    final provider = _FakeExchangeRateService({'USD': 52, 'EUR': 56});
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: provider,
      now: () => now,
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(provider.calls, 1);
    expect(refreshed.conversionRates, {'USD': 52, 'EUR': 56});
  });

  test('keeps stale saved rates when provider fails', () async {
    final settings = _settings(
      userId: 'user-offline',
      conversionRates: const {'USD': 49},
      exchangeRatesUpdatedAt: DateTime(2026, 5, 17, 9),
    );
    final repository = FakeSettingsRepository(settings);
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: const _ThrowingExchangeRateService(),
      now: () => DateTime(2026, 5, 19, 9),
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(refreshed.conversionRates, {'USD': 49});
    expect(refreshed.exchangeRatesUpdatedAt, DateTime(2026, 5, 17, 9));
    expect(repository.settings.conversionRates, {'USD': 49});
  });

  test('leaves missing rates missing when provider fails and no cache exists',
      () async {
    final settings = _settings(userId: 'user-missing');
    final repository = FakeSettingsRepository(settings);
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: const _ThrowingExchangeRateService(),
      now: () => DateTime(2026, 5, 19, 9),
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(refreshed.conversionRates, isEmpty);
    expect(refreshed.exchangeRatesUpdatedAt, isNull);
  });

  test('keeps cleared rates missing when provider fails after base change',
      () async {
    final settings = _settings(
      userId: 'user-base-changed-offline',
      baseCurrency: 'USD',
      supportedCurrencies: const ['USD', 'EGP'],
      conversionRates: const {},
      exchangeRatesUpdatedAt: null,
    );
    final repository = FakeSettingsRepository(settings);
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: const _ThrowingExchangeRateService(),
      now: () => DateTime(2026, 5, 19, 9),
    );

    final refreshed = await service.refreshIfNeeded(settings);

    expect(refreshed.conversionRates, isEmpty);
    expect(refreshed.exchangeRatesUpdatedAt, isNull);
    expect(repository.settings.conversionRates, isEmpty);
  });

  test('requests only supported non-base currencies', () async {
    final settings = _settings(
      userId: 'user-scope',
      baseCurrency: 'USD',
      supportedCurrencies: const ['USD', 'EGP', 'EUR', 'USD'],
    );
    final repository = FakeSettingsRepository(settings);
    final provider = _FakeExchangeRateService({'EGP': 0.02, 'EUR': 1.1});
    final service = ExchangeRateRefreshService(
      settingsRepository: repository,
      exchangeRateService: provider,
      now: () => DateTime(2026, 5, 19, 9),
    );

    await service.refreshIfNeeded(settings);

    expect(provider.requestedQuotes.single, ['EGP', 'EUR']);
    expect(repository.settings.conversionRates, {'EGP': 0.02, 'EUR': 1.1});
  });
}

UserSettings _settings({
  required String userId,
  String baseCurrency = 'EGP',
  List<String> supportedCurrencies = const ['EGP', 'USD', 'EUR'],
  Map<String, num>? conversionRates,
  DateTime? exchangeRatesUpdatedAt,
  DateTime? updatedAt,
}) {
  return UserSettings.defaults(
    userId: userId,
    updatedAt: updatedAt ?? DateTime(2026, 5, 18),
  ).copyWith(
    baseCurrency: baseCurrency,
    supportedCurrencies: supportedCurrencies,
    conversionRates: conversionRates,
    exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
  );
}

class _FakeExchangeRateService implements ExchangeRateService {
  _FakeExchangeRateService(this.rates);

  final Map<String, double> rates;
  final requestedQuotes = <List<String>>[];
  int calls = 0;

  @override
  Future<Map<String, double>> latestRates({
    required String baseCurrency,
    required Iterable<String> quoteCurrencies,
  }) async {
    calls += 1;
    final quotes = quoteCurrencies.map((value) => value.toUpperCase()).toList()
      ..sort();
    requestedQuotes.add(quotes);
    return {
      for (final quote in quotes)
        if (rates.containsKey(quote)) quote: rates[quote]!,
    };
  }
}

class _ThrowingExchangeRateService implements ExchangeRateService {
  const _ThrowingExchangeRateService();

  @override
  Future<Map<String, double>> latestRates({
    required String baseCurrency,
    required Iterable<String> quoteCurrencies,
  }) async {
    throw const ExchangeRateException('offline');
  }
}
