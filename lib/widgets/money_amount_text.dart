import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

class MoneyAmountText extends StatelessWidget {
  const MoneyAmountText({
    this.amount,
    this.currencyCode,
    this.formattedAmount,
    this.secondaryText,
    this.textAlign,
    super.key,
  }) : assert(
         formattedAmount != null || (amount != null && currencyCode != null),
         'Provide formattedAmount or amount with currencyCode.',
       );

  final String? amount;
  final String? currencyCode;
  final String? formattedAmount;
  final String? secondaryText;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final align =
        textAlign ??
        (direction == TextDirection.rtl ? TextAlign.right : TextAlign.left);
    final amountLine = formattedAmount ?? '$amount $currencyCode';

    return Column(
      crossAxisAlignment: direction == TextDirection.rtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: direction == TextDirection.rtl
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(
            amountLine,
            textAlign: align,
            maxLines: 1,
            style: AppTextStyles.amount(context),
          ),
        ),
        if (secondaryText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            secondaryText!,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context),
          ),
        ],
      ],
    );
  }
}
