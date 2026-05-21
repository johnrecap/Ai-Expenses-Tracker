import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ExchangeRateService {
  /// Returns rates keyed by source currency, where each rate is the value of
  /// one source-currency unit in [baseCurrency].
  Future<Map<String, double>> latestRates({
    required String baseCurrency,
    required Iterable<String> quoteCurrencies,
  });
}

class FrankfurterExchangeRateService implements ExchangeRateService {
  const FrankfurterExchangeRateService({
    this.client,
    this.timeout = const Duration(seconds: 6),
  });

  final http.Client? client;
  final Duration timeout;

  @override
  Future<Map<String, double>> latestRates({
    required String baseCurrency,
    required Iterable<String> quoteCurrencies,
  }) async {
    final base = _normalize(baseCurrency);
    final quotes = quoteCurrencies.map(_normalize).where((quote) {
      return quote.isNotEmpty && quote != base;
    }).toSet();
    if (base.isEmpty || quotes.isEmpty) return const {};

    final rates = <String, double>{};
    for (final quote in quotes) {
      rates[quote] = await _fetchRate(base: quote, quote: base);
    }
    return rates;
  }

  Future<double> _fetchRate({
    required String base,
    required String quote,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.https(
        'api.frankfurter.dev',
        '/v2/rate/$base/$quote',
      );
      final response = await httpClient.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw ExchangeRateException(
          'Exchange rate request failed with HTTP ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ExchangeRateException('Exchange rate response is invalid.');
      }
      final value = decoded['rate'];
      if (value is! num || value <= 0) {
        throw const ExchangeRateException('Exchange rate value is missing.');
      }
      return value.toDouble();
    } on TimeoutException catch (error) {
      throw ExchangeRateException('Exchange rate request timed out.', error);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  String _normalize(String currency) => currency.trim().toUpperCase();
}

class ExchangeRateException implements Exception {
  const ExchangeRateException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
