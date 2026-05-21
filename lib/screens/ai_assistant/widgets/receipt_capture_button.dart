import 'dart:typed_data';

import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptCaptureButton extends StatefulWidget {
  const ReceiptCaptureButton({
    required this.service,
    required this.aiContext,
    required this.onExtracted,
    required this.onUnavailable,
    super.key,
  });

  final ReceiptAiService service;
  final AiContext aiContext;
  final ValueChanged<ReceiptAiResult> onExtracted;
  final ValueChanged<AiUsageStatus> onUnavailable;

  @override
  State<ReceiptCaptureButton> createState() => _ReceiptCaptureButtonState();
}

class _ReceiptCaptureButtonState extends State<ReceiptCaptureButton> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _chooseSource,
      icon: _loading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.receipt_long),
      label: Text(context.l10n.receipt),
    );
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(context.l10n.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pick(source);
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _loading = true);
    final imageReadFailedMessage = context.l10n.receiptImageReadFailed;
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final result = await widget.service.extractReceipt(
        imageBytes: Uint8List.fromList(bytes),
        mimeType: file.mimeType ?? _mimeTypeFromPath(file.path),
        context: widget.aiContext,
      );
      if (result.payload == null && result.usageStatus != null) {
        widget.onUnavailable(result.usageStatus!);
      } else {
        widget.onExtracted(result);
      }
    } catch (error) {
      widget.onUnavailable(
        AiUsageStatus(
          requestType: AiUsageRequestType.receiptExtraction,
          allowed: false,
          fallbackReason: AiFallbackReason.functionsUnavailable,
          message: imageReadFailedMessage,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
