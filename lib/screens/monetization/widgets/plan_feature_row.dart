import 'package:flutter/material.dart';

class PlanFeatureRow extends StatelessWidget {
  const PlanFeatureRow({
    required this.label,
    required this.freeValue,
    required this.premiumValue,
    super.key,
  });

  final String label;
  final String freeValue;
  final String premiumValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(freeValue)),
          Expanded(child: Text(premiumValue)),
        ],
      ),
    );
  }
}
