import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as image;

import '../models/models.dart';
import 'ai_gateway_client.dart';
import 'ai_gateway_error.dart';
import 'ai_service.dart';
import 'ai_usage_fallback_service.dart';

class ReceiptAiResult {
  const ReceiptAiResult({
    this.payload,
    this.usageStatus,
    this.providerMetadata,
    required this.imageFingerprint,
  });

  final AiReceiptPayload? payload;
  final AiUsageStatus? usageStatus;
  final AiProviderMetadata? providerMetadata;
  final String imageFingerprint;
}

class PreparedReceiptImage {
  const PreparedReceiptImage({
    required this.bytes,
    required this.mimeType,
    required this.fingerprint,
  });

  final Uint8List bytes;
  final String mimeType;
  final String fingerprint;
}

abstract class ReceiptAiService {
  Future<ReceiptAiResult> extractReceipt({
    required Uint8List imageBytes,
    required String mimeType,
    required AiContext context,
  });
}

class GatewayReceiptAiService implements ReceiptAiService {
  GatewayReceiptAiService({
    required AiGatewayClient client,
    AiUsageFallbackService fallbackService = const AiUsageFallbackService(),
    this.maxDimension = 1280,
    this.jpegQuality = 78,
  })  : _client = client,
        _fallbackService = fallbackService;

  final AiGatewayClient _client;
  final AiUsageFallbackService _fallbackService;
  final int maxDimension;
  final int jpegQuality;

  static final Map<String, _ReceiptCacheEntry> _cache = {};

  @override
  Future<ReceiptAiResult> extractReceipt({
    required Uint8List imageBytes,
    required String mimeType,
    required AiContext context,
  }) async {
    final prepared = preprocessReceiptImage(
      imageBytes,
      mimeType: mimeType,
      maxDimension: maxDimension,
      jpegQuality: jpegQuality,
    );
    final cacheKey = _cacheKey(context.userId, prepared.fingerprint);
    final cached = _cache[cacheKey];
    if (cached != null && !_isExpired(cached.createdAt, context.now)) {
      return ReceiptAiResult(
        payload: cached.payload,
        usageStatus: cached.usageStatus,
        providerMetadata: cached.providerMetadata,
        imageFingerprint: prepared.fingerprint,
      );
    }

    try {
      final result = await _client.extractReceipt(
        imageBase64: base64Encode(prepared.bytes),
        mimeType: prepared.mimeType,
        imageFingerprint: prepared.fingerprint,
        context: context,
      );
      final usageStatus = result.usageStatus == null
          ? null
          : AiUsageStatus.fromJson(result.usageStatus);
      final payload = AiReceiptPayload.fromJson(result.structuredJson);
      final effectiveStatus =
          payload.hasLowConfidence || payload.missingFields().isNotEmpty
              ? (usageStatus ??
                      _fallbackService.lowConfidence(
                        AiUsageRequestType.receiptExtraction,
                      ))
                  .copyWith(
                  fallbackReason: AiFallbackReason.lowConfidence,
                  message: 'Review and complete the fields before saving.',
                )
              : usageStatus;
      _cache[cacheKey] = _ReceiptCacheEntry(
        payload: payload,
        usageStatus: effectiveStatus,
        providerMetadata: result.metadata,
        createdAt: context.now,
      );
      return ReceiptAiResult(
        payload: payload,
        usageStatus: effectiveStatus,
        providerMetadata: result.metadata,
        imageFingerprint: prepared.fingerprint,
      );
    } on AiGatewayException catch (error) {
      return ReceiptAiResult(
        usageStatus: _fallbackService.fromGatewayError(
          error,
          AiUsageRequestType.receiptExtraction,
        ),
        imageFingerprint: prepared.fingerprint,
      );
    }
  }
}

PreparedReceiptImage preprocessReceiptImage(
  Uint8List bytes, {
  required String mimeType,
  int maxDimension = 1280,
  int jpegQuality = 78,
}) {
  final decoded = image.decodeImage(bytes);
  if (decoded == null) {
    return PreparedReceiptImage(
      bytes: bytes,
      mimeType: mimeType,
      fingerprint: sha256.convert(bytes).toString(),
    );
  }

  final longestSide =
      decoded.width > decoded.height ? decoded.width : decoded.height;
  final resized = longestSide > maxDimension
      ? image.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? maxDimension : null,
          height: decoded.height > decoded.width ? maxDimension : null,
        )
      : decoded;
  final encoded = Uint8List.fromList(
    image.encodeJpg(resized, quality: jpegQuality),
  );
  return PreparedReceiptImage(
    bytes: encoded,
    mimeType: 'image/jpeg',
    fingerprint: sha256.convert(encoded).toString(),
  );
}

class _ReceiptCacheEntry {
  const _ReceiptCacheEntry({
    required this.payload,
    required this.usageStatus,
    required this.providerMetadata,
    required this.createdAt,
  });

  final AiReceiptPayload payload;
  final AiUsageStatus? usageStatus;
  final AiProviderMetadata providerMetadata;
  final DateTime createdAt;
}

String _cacheKey(String? userId, String fingerprint) {
  return '${userId ?? 'anonymous'}:$fingerprint';
}

bool _isExpired(DateTime createdAt, DateTime now) {
  return createdAt.year != now.year ||
      createdAt.month != now.month ||
      createdAt.day != now.day;
}
