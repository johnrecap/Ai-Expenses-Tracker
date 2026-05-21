import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';

class ExchangeRateRefreshService {
  ExchangeRateRefreshService({
    required SettingsRepository settingsRepository,
    ExchangeRateService exchangeRateService =
        const FrankfurterExchangeRateService(),
    DateTime Function()? now,
  })  : _settingsRepository = settingsRepository,
        _exchangeRateService = exchangeRateService,
        _now = now ?? DateTime.now;

  final SettingsRepository _settingsRepository;
  final ExchangeRateService _exchangeRateService;
  final DateTime Function() _now;

  static final Map<String, Future<UserSettings>> _inFlight = {};

  Future<UserSettings> refreshIfNeeded(UserSettings settings) {
    final now = _now();
    if (_isFreshForToday(settings.exchangeRatesUpdatedAt, now)) {
      return Future.value(settings);
    }

    final baseCurrency = _normalize(settings.baseCurrency);
    final targets = _targetCurrencies(settings, baseCurrency);
    final refreshKey = [
      settings.userId,
      _localDateKey(now),
      baseCurrency,
      targets.join(','),
    ].join('|');

    return _inFlight.putIfAbsent(refreshKey, () async {
      try {
        return await _refresh(settings, baseCurrency, targets, now);
      } finally {
        _inFlight.remove(refreshKey);
      }
    });
  }

  Future<UserSettings> _refresh(
    UserSettings settings,
    String baseCurrency,
    List<String> targets,
    DateTime now,
  ) async {
    if (baseCurrency.isEmpty || targets.isEmpty) {
      await _settingsRepository.updateExchangeRates(
        conversionRates: settings.conversionRates,
        exchangeRatesUpdatedAt: now,
      );
      return settings.copyWith(exchangeRatesUpdatedAt: now, updatedAt: now);
    }

    try {
      final providerRates = await _exchangeRateService.latestRates(
        baseCurrency: baseCurrency,
        quoteCurrencies: targets,
      );
      final validRates = _validRates(providerRates, targets.toSet());
      if (validRates.isEmpty) return settings;

      final mergedRates = <String, num>{
        ...settings.conversionRates,
        ...validRates,
      };
      await _settingsRepository.updateExchangeRates(
        conversionRates: mergedRates,
        exchangeRatesUpdatedAt: now,
      );
      return settings.copyWith(
        conversionRates: mergedRates,
        exchangeRatesUpdatedAt: now,
        updatedAt: now,
      );
    } catch (_) {
      return settings;
    }
  }

  Map<String, double> _validRates(
    Map<String, double> rates,
    Set<String> targets,
  ) {
    final valid = <String, double>{};
    for (final entry in rates.entries) {
      final currency = _normalize(entry.key);
      final rate = entry.value;
      if (currency.isEmpty ||
          !targets.contains(currency) ||
          rate <= 0 ||
          !rate.isFinite) {
        continue;
      }
      valid[currency] = rate;
    }
    return valid;
  }

  List<String> _targetCurrencies(UserSettings settings, String baseCurrency) {
    final currencies = <String>{};
    for (final value in settings.supportedCurrencies) {
      final currency = _normalize(value);
      if (currency.isEmpty || currency == baseCurrency) continue;
      currencies.add(currency);
    }
    return currencies.toList()..sort();
  }

  bool _isFreshForToday(DateTime? refreshedAt, DateTime now) {
    if (refreshedAt == null) return false;
    return refreshedAt.year == now.year &&
        refreshedAt.month == now.month &&
        refreshedAt.day == now.day;
  }

  String _localDateKey(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _normalize(String currency) => currency.trim().toUpperCase();
}
