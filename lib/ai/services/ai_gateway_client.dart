import 'dart:async';
import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:http/http.dart' as http;

import '../models/ai_provider_metadata.dart';
import '../models/ai_usage_status.dart';
import 'ai_gateway_error.dart';
import 'ai_provider_config.dart';
import 'ai_service.dart';

typedef AiGatewayTokenProvider = Future<String?> Function();
typedef AiGatewayRequestSender = Future<AiGatewayHttpResponse> Function(
  Uri uri,
  Map<String, String> headers,
  Map<String, Object?> body,
  Duration timeout,
);

class AiGatewayHttpResponse {
  const AiGatewayHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

class AiGatewayResult {
  const AiGatewayResult({
    required this.structuredJson,
    required this.metadata,
    this.usageStatus,
  });

  final String structuredJson;
  final AiProviderMetadata metadata;
  final AiUsageStatus? usageStatus;
}

class AiGatewayStructuredResult {
  const AiGatewayStructuredResult({
    required this.structuredJson,
    required this.metadata,
    this.usageStatus,
  });

  final Map<String, dynamic> structuredJson;
  final AiProviderMetadata metadata;
  final Map<String, dynamic>? usageStatus;
}

class AiGatewayClient {
  AiGatewayClient({
    required AiProviderConfig config,
    required AiGatewayTokenProvider tokenProvider,
    AiGatewayRequestSender? sender,
  })  : _config = config,
        _tokenProvider = tokenProvider,
        _sender = sender ?? _defaultSender;

  final AiProviderConfig _config;
  final AiGatewayTokenProvider _tokenProvider;
  final AiGatewayRequestSender _sender;

  Future<AiGatewayResult> parse(String input, AiContext context) async {
    final decoded = await _send(
      endpointName: null,
      body: _requestBody(input, context),
    );
    final structured = decoded['structuredJson'];
    if (structured == null) {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.invalidProviderOutput,
        message: 'Gateway response did not include structuredJson.',
      );
    }

    return AiGatewayResult(
      structuredJson:
          structured is String ? structured : jsonEncode(structured),
      metadata: AiProviderMetadata.fromJson(decoded),
      usageStatus: _parseUsageStatus(decoded['quota']),
    );
  }

  Future<AiGatewayStructuredResult> extractReceipt({
    required String imageBase64,
    required String mimeType,
    required String imageFingerprint,
    required AiContext context,
  }) async {
    final decoded = await _send(
      endpointName: 'aiReceipt',
      body: {
        'imageBase64': imageBase64,
        'mimeType': mimeType,
        'imageFingerprint': imageFingerprint,
        'now': context.now.toIso8601String(),
        'locale': context.locale,
        'defaultCurrency': context.defaultCurrency,
        'defaultPaymentMethod': context.defaultPaymentMethod.label,
        'clientRequestId': DateTime.now().microsecondsSinceEpoch.toString(),
        'categories': context.categories
            .map((category) => {
                  'categoryId': category.categoryId,
                  'name': category.name,
                  'isArchived': category.isArchived,
                })
            .toList(),
      },
    );
    return _parseStructuredResult(decoded);
  }

  Future<AiGatewayStructuredResult> financialAdvice({
    required String period,
    required Map<String, Object?> summary,
    required AiContext context,
  }) async {
    final decoded = await _send(
      endpointName: 'aiAdvice',
      body: {
        'period': period,
        'summary': summary,
        'now': context.now.toIso8601String(),
        'locale': context.locale,
        'defaultCurrency': context.defaultCurrency,
        'defaultPaymentMethod': context.defaultPaymentMethod.label,
        'clientRequestId': DateTime.now().microsecondsSinceEpoch.toString(),
      },
    );
    return _parseStructuredResult(decoded);
  }

  Future<Map<String, dynamic>> _send({
    required String? endpointName,
    required Map<String, Object?> body,
  }) async {
    if (!_config.enabled) {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.gatewayMisconfigured,
        message: 'AI gateway is disabled.',
      );
    }

    final token = await _tokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.unauthenticated,
        message: 'Missing authentication token.',
      );
    }

    late final AiGatewayHttpResponse response;
    try {
      response = await _sender(
        _endpoint(endpointName),
        {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body,
        _config.timeout,
      );
    } on TimeoutException {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.providerTimeout,
        message: 'AI gateway request timed out.',
      );
    } on http.ClientException {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.networkFailure,
        message: 'AI gateway is unavailable.',
      );
    }
    return _parseResponse(response);
  }

  Map<String, Object?> _requestBody(String input, AiContext context) {
    final recentExpenses = [...context.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    return {
      'input': input.trim(),
      'now': context.now.toIso8601String(),
      'locale': context.locale,
      'defaultCurrency': context.defaultCurrency,
      'defaultPaymentMethod': context.defaultPaymentMethod.label,
      'clientRequestId': DateTime.now().microsecondsSinceEpoch.toString(),
      'categories': context.categories
          .map((category) => {
                'categoryId': category.categoryId,
                'name': category.name,
                'isArchived': category.isArchived,
              })
          .toList(),
      'recentExpenses': recentExpenses.take(25).map(_expenseSnapshot).toList(),
      if (context.budget != null)
        'budgetSummary': _budgetSnapshot(context.budget!),
    };
  }

  Map<String, Object?> _expenseSnapshot(Expense expense) {
    return {
      'expenseId': expense.expenseId,
      'amount': expense.amount,
      'currency': expense.currency,
      'categoryName': expense.categoryName,
      'description': expense.description,
      'date': _dateOnly(expense.date),
      'paymentMethod': expense.paymentMethod.label,
    };
  }

  Map<String, Object?> _budgetSnapshot(Budget budget) {
    return {
      'month': '${budget.year.toString().padLeft(4, '0')}-'
          '${budget.month.toString().padLeft(2, '0')}',
      'currency': budget.currency,
      'limit': budget.amount,
      'warningThreshold': budget.warningThresholdPercent / 100,
    };
  }

  Map<String, dynamic> _parseResponse(AiGatewayHttpResponse response) {
    late final Map<String, dynamic> decoded;
    try {
      decoded = _decode(response.body);
    } on AiGatewayException {
      final statusError = _errorForStatusCode(response.statusCode);
      if (statusError != null) throw statusError;
      rethrow;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiGatewayException(
        code: AiGatewayErrorCode.fromValue(decoded['errorCode'] as String?) ==
                AiGatewayErrorCode.unknown
            ? _codeForStatusCode(response.statusCode)
            : AiGatewayErrorCode.fromValue(decoded['errorCode'] as String?),
        message: decoded['errorMessage'] as String? ?? 'AI gateway failed.',
        provider: decoded['provider'] as String?,
        model: decoded['model'] as String?,
        requestId: decoded['requestId'] as String?,
        usageStatus: _parseUsageStatus(decoded['quota']),
      );
    }

    final ok = decoded['ok'] == true;
    if (!ok) {
      throw AiGatewayException(
        code: AiGatewayErrorCode.fromValue(decoded['errorCode'] as String?),
        message: decoded['errorMessage'] as String? ?? 'AI gateway failed.',
        provider: decoded['provider'] as String?,
        model: decoded['model'] as String?,
        requestId: decoded['requestId'] as String?,
        usageStatus: _parseUsageStatus(decoded['quota']),
      );
    }

    return decoded;
  }

  AiGatewayStructuredResult _parseStructuredResult(
      Map<String, dynamic> decoded) {
    final structured = decoded['structuredJson'];
    if (structured is! Map) {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.invalidProviderOutput,
        message: 'Gateway structuredJson must be a JSON object.',
      );
    }
    return AiGatewayStructuredResult(
      structuredJson: Map<String, dynamic>.from(structured),
      metadata: AiProviderMetadata.fromJson(decoded),
      usageStatus: _parseUsageMap(decoded['quota']),
    );
  }

  AiUsageStatus? _parseUsageStatus(Object? value) {
    final usage = _parseUsageMap(value);
    return usage == null ? null : AiUsageStatus.fromJson(usage);
  }

  Map<String, dynamic>? _parseUsageMap(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      throw const AiGatewayException(
        code: AiGatewayErrorCode.invalidProviderOutput,
        message: 'Gateway response was not valid JSON.',
      );
    }
    throw const AiGatewayException(
      code: AiGatewayErrorCode.invalidProviderOutput,
      message: 'Gateway response must be a JSON object.',
    );
  }

  AiGatewayException? _errorForStatusCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return null;
    return AiGatewayException(
      code: _codeForStatusCode(statusCode),
      message: 'AI gateway returned HTTP $statusCode.',
    );
  }

  AiGatewayErrorCode _codeForStatusCode(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return AiGatewayErrorCode.unauthenticated;
    }
    if (statusCode == 408 || statusCode == 504) {
      return AiGatewayErrorCode.providerTimeout;
    }
    if (statusCode == 429) return AiGatewayErrorCode.rateLimited;
    if (statusCode >= 500) return AiGatewayErrorCode.providerUnavailable;
    if (statusCode >= 400) return AiGatewayErrorCode.invalidRequest;
    return AiGatewayErrorCode.unknown;
  }

  static Future<AiGatewayHttpResponse> _defaultSender(
    Uri uri,
    Map<String, String> headers,
    Map<String, Object?> body,
    Duration timeout,
  ) async {
    final encodedBody = utf8.encode(jsonEncode(body));
    final response = await http
        .post(uri, headers: headers, body: encodedBody)
        .timeout(timeout);
    return AiGatewayHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Uri _endpoint(String? endpointName) {
    final base = Uri.parse(_config.gatewayUrl);
    if (endpointName == null || endpointName.trim().isEmpty) {
      if (base.pathSegments.isEmpty ||
          (base.pathSegments.length == 1 && base.pathSegments.first.isEmpty)) {
        return base.replace(pathSegments: ['aiParse']);
      }
      return base;
    }
    final segments = [...base.pathSegments];
    if (segments.isEmpty || (segments.length == 1 && segments.first.isEmpty)) {
      return base.replace(pathSegments: [endpointName]);
    }
    segments[segments.length - 1] = endpointName;
    return base.replace(pathSegments: segments);
  }

  String _dateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
