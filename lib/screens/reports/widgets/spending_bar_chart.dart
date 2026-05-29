import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingBarChart extends StatelessWidget {
  final List<ReportBucket> buckets;
  final ValueChanged<ReportBucket>? onBucketTap;

  const SpendingBarChart({super.key, required this.buckets, this.onBucketTap});

  @override
  Widget build(BuildContext context) {
    final maxTotal = buckets.fold<double>(
      0,
      (maxValue, bucket) => max(maxValue, bucket.total),
    );
    final top = maxTotal == 0 ? 1.0 : maxTotal * 1.2;

    return BarChart(
      BarChartData(
        maxY: top,
        barTouchData: BarTouchData(
          enabled: onBucketTap != null,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) return;
            final index = response?.spot?.touchedBarGroupIndex;
            if (index == null || index < 0 || index >= buckets.length) return;
            onBucketTap?.call(buckets[index]);
          },
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    buckets[index].label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].total,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: top,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
