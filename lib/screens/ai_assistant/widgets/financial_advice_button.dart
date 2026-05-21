import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

class FinancialAdviceButton extends StatefulWidget {
  const FinancialAdviceButton({
    required this.service,
    required this.aiContext,
    required this.onAdvice,
    super.key,
  });

  final FinancialAdviceAiService service;
  final AiContext aiContext;
  final ValueChanged<AiFinancialAdvicePayload> onAdvice;

  @override
  State<FinancialAdviceButton> createState() => _FinancialAdviceButtonState();
}

class _FinancialAdviceButtonState extends State<FinancialAdviceButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _choosePeriod,
      icon: _loading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.tips_and_updates),
      label: Text(context.l10n.advice),
    );
  }

  Future<void> _choosePeriod() async {
    final period = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.view_week),
              title: Text(context.l10n.thisWeek),
              onTap: () => Navigator.pop(context, 'week'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(context.l10n.thisMonth),
              onTap: () => Navigator.pop(context, 'month'),
            ),
          ],
        ),
      ),
    );
    if (period == null) return;
    setState(() => _loading = true);
    try {
      widget.onAdvice(
        await widget.service.requestAdvice(
          period: period,
          context: widget.aiContext,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
