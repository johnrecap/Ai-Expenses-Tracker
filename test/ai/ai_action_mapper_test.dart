import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_search_payload.dart';
import 'package:expenses_tracker/ai/services/ai_response_parser.dart';
import 'package:expenses_tracker/ai/services/ai_action_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Arabic current month search to an expense filter', () {
    final filter = AiActionMapper.searchPayloadToFilter(
      const AiSearchPayload(
        query: 'اكل',
        categoryNames: ['Food'],
        periodText: 'الشهر ده',
        currency: 'egp',
      ),
      now: DateTime(2026, 5, 15),
    );

    expect(filter.query, 'اكل');
    expect(filter.categoryIds, contains('food'));
    expect(filter.startDate, DateTime(2026, 5, 1));
    expect(filter.endDate, DateTime(2026, 5, 31, 23, 59, 59, 999));
    expect(filter.currency, 'EGP');
  });

  test('infers Arabic payment method labels from text', () {
    expect(
      AiActionMapper.paymentMethodsFromText('دفعت بالكاش'),
      [PaymentMethod.cash],
    );
    expect(
      AiActionMapper.paymentMethodsFromText('اشتريت بالفيزا'),
      [PaymentMethod.visa],
    );
  });

  test('parser accepts search, summary, and advice intents', () {
    final search = AiResponseParser.parse(
      '{"intent":"search_expenses","query":"food","confidence":0.9,"needsConfirmation":true}',
    );
    final summary = AiResponseParser.parse(
      '{"intent":"summarize_expenses","period":"weekly","confidence":0.9,"needsConfirmation":true}',
    );
    final advice = AiResponseParser.parse(
      '{"intent":"financial_advice","period":"monthly","confidence":0.9,"needsConfirmation":true}',
    );

    expect(search.searchPayload?.query, 'food');
    expect(summary.summaryPayload?.period, ReportRangeType.weekly);
    expect(advice.advicePayload?.period, ReportRangeType.monthly);
  });
}
