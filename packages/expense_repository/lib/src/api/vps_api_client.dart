import 'dart:convert';

import 'package:http/http.dart' as http;

typedef FirebaseTokenProvider = Future<String?> Function();

class VpsApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;
  final bool retryable;

  const VpsApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.retryable = false,
  });

  @override
  String toString() => '$code: $message';
}

class VpsApiClient {
  final Uri baseUri;
  final FirebaseTokenProvider tokenProvider;
  final http.Client _client;

  VpsApiClient({
    required this.baseUri,
    required this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, Object?>> getJson(String path) async {
    final response = await _client.get(
      _resolve(path),
      headers: await _headers(),
    );
    return _decodeMap(response);
  }

  Future<Map<String, Object?>> postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.post(
      _resolve(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decodeMap(response);
  }

  Future<Map<String, Object?>> patchJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.patch(
      _resolve(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decodeMap(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) {
      throw const VpsApiException(
        code: 'auth/missing-local-token',
        message: 'Firebase authentication token is not available.',
        retryable: true,
      );
    }
    return {
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
      'accept': 'application/json',
    };
  }

  Uri _resolve(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(normalized);
  }

  Map<String, Object?> _decodeMap(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, Object?>{}
        : jsonDecode(response.body) as Object?;
    final map = decoded is Map<String, Object?>
        ? decoded
        : Map<String, Object?>.from(decoded as Map);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw VpsApiException(
      statusCode: response.statusCode,
      code: map['code']?.toString() ?? 'http/${response.statusCode}',
      message: map['message']?.toString() ?? 'Backend request failed.',
      retryable: map['retryable'] == true,
    );
  }
}
