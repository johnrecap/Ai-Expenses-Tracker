import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('VpsApiConfig', () {
    test('normalizes configured base URL with trailing slash', () {
      final config = VpsApiConfig.fromEnvironment(
        value: 'https://api.saeeddev.com',
      );

      expect(config.baseUri.toString(), 'https://api.saeeddev.com/');
    });

    test('requires a base URL outside firebase legacy mode', () {
      final config = VpsApiConfig.fromEnvironment(value: '');

      expect(
        () => config.requireForMode(RepositoryRuntimeMode.vpsLocalFirst),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('VpsApiClient', () {
    test('sends Firebase bearer token on requests', () async {
      late Map<String, String> headers;
      final client = VpsApiClient(
        baseUri: Uri.parse('https://api.example.com/'),
        tokenProvider: () async => 'firebase-token',
        client: MockClient((request) async {
          headers = request.headers;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await client.getJson('/v1/users/me');

      expect(headers['authorization'], 'Bearer firebase-token');
      expect(headers['accept'], 'application/json');
    });

    test('maps backend error envelopes to VpsApiException', () async {
      final client = VpsApiClient(
        baseUri: Uri.parse('https://api.example.com/'),
        tokenProvider: () async => 'firebase-token',
        client: MockClient(
          (_) async => http.Response(
            '{"code":"auth/invalid-token","message":"Expired","retryable":true}',
            401,
          ),
        ),
      );

      expect(
        () => client.getJson('/v1/users/me'),
        throwsA(
          isA<VpsApiException>()
              .having((error) => error.code, 'code', 'auth/invalid-token')
              .having((error) => error.retryable, 'retryable', true),
        ),
      );
    });

    test('fails locally when Firebase token is missing', () async {
      final client = VpsApiClient(
        baseUri: Uri.parse('https://api.example.com/'),
        tokenProvider: () async => null,
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        () => client.getJson('/v1/users/me'),
        throwsA(
          isA<VpsApiException>().having(
            (error) => error.code,
            'code',
            'auth/missing-local-token',
          ),
        ),
      );
    });
  });
}
