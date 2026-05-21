import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('fetches source-to-base Frankfurter pair rates', () async {
    final requests = <Uri>[];
    final service = FrankfurterExchangeRateService(
      client: MockClient((request) async {
        requests.add(request.url);
        return http.Response('{"rate": 50.25}', 200);
      }),
    );

    final rates = await service.latestRates(
      baseCurrency: 'EGP',
      quoteCurrencies: const ['usd'],
    );

    expect(rates, {'USD': 50.25});
    expect(requests.single.host, 'api.frankfurter.dev');
    expect(requests.single.path, '/v2/rate/USD/EGP');
  });

  test('throws when provider response does not include a valid rate', () async {
    final service = FrankfurterExchangeRateService(
      client: MockClient((request) async {
        return http.Response('{"message":"Could not find currency"}', 404);
      }),
    );

    expect(
      service.latestRates(
        baseCurrency: 'EGP',
        quoteCurrencies: const ['ABC'],
      ),
      throwsA(isA<ExchangeRateException>()),
    );
  });
}
