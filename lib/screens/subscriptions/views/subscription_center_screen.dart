import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/recurring_expenses/blocs/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/screens/recurring_expenses/views/recurring_expenses_screen.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/screens/subscriptions/services/subscription_summary_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SubscriptionCenterScreen extends StatelessWidget {
  final SubscriptionSummaryService summaryService;

  const SubscriptionCenterScreen({
    super.key,
    this.summaryService = const SubscriptionSummaryService(),
  });

  void _openRecurringManager(BuildContext context) {
    final recurringExpenseRepository =
        context.read<RecurringExpenseRepository>();
    final categoryRepository = context.read<CategoryRepository>();
    SettingsRepository? settingsRepository;
    try {
      settingsRepository = context.read<SettingsRepository>();
    } catch (_) {
      settingsRepository = null;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<CategoryRepository>.value(
              value: categoryRepository,
            ),
            if (settingsRepository != null)
              RepositoryProvider<SettingsRepository>.value(
                value: settingsRepository,
              ),
          ],
          child: BlocProvider(
            create: (_) => RecurringExpenseBloc(recurringExpenseRepository)
              ..add(const RecurringExpensesWatchRequested()),
            child: const RecurringExpensesScreen(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recurringExpenseRepository =
        context.read<RecurringExpenseRepository>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(context.l10n.subscriptionCenter),
        actions: [
          IconButton(
            tooltip: context.l10n.manageRecurringExpenses,
            onPressed: () => _openRecurringManager(context),
            icon: const Icon(Icons.edit_calendar_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<RecurringExpense>>(
        stream: recurringExpenseRepository.watchRecurringExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.failedToLoadSubscriptions,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final summaries = summaryService.summarize(
            rules: snapshot.data ?? const [],
          );
          final upcomingRenewals = summaryService.upcomingRenewals(
            summaries,
          );
          final priceChangeCandidates = summaryService.priceChangeCandidates(
            rules: snapshot.data ?? const [],
          );
          if (summaries.isEmpty) {
            return _EmptySubscriptions(
              onManage: () => _openRecurringManager(context),
            );
          }

          return StreamBuilder<UserSettings>(
            stream: context.read<SettingsRepository>().watchSettings(),
            builder: (context, settingsSnapshot) {
              final monthlyImpact = summaryService.monthlyImpact(
                summaries,
                settings: settingsSnapshot.data,
              );
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MonthlyImpactHeader(impact: monthlyImpact),
                  if (upcomingRenewals.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _UpcomingRenewalsSection(renewals: upcomingRenewals),
                  ],
                  if (priceChangeCandidates.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _PriceChangeCandidatesSection(
                      candidates: priceChangeCandidates,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _SectionTitle(title: context.l10n.activeSubscriptions),
                  const SizedBox(height: 8),
                  ...summaries.map(
                    (summary) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubscriptionTile(
                        summary: summary,
                        onEdit: () => _openRecurringManager(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthlyImpactHeader extends StatelessWidget {
  final SubscriptionMonthlyImpact impact;

  const _MonthlyImpactHeader({required this.impact});

  @override
  Widget build(BuildContext context) {
    final totalLabels = impact.totalsByCurrency.entries
        .map(
          (entry) => formatAmountWithCurrency(entry.value, entry.key),
        )
        .join(' + ');
    final metadataLines = _monthlyImpactMetadataLines(context, impact);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.estimatedMonthlyImpact,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalLabels,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (impact.caveats.isNotEmpty || metadataLines.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...impact.caveats.map(
              (caveat) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _CaveatText(caveat: caveat),
              ),
            ),
            ...metadataLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _InfoText(text: line),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<String> _monthlyImpactMetadataLines(
  BuildContext context,
  SubscriptionMonthlyImpact impact,
) {
  final lines = <String>[];
  if (impact.hasConvertedCurrencies) {
    lines.add(
      context.l10n.convertedCurrenciesStatus(
        impact.convertedCurrencies.join(', '),
      ),
    );
  }
  if (impact.hasUnconvertedCurrencies) {
    lines.add(
      context.l10n.unconvertedCurrenciesStatus(
        impact.unconvertedRuleCount,
        impact.unconvertedCurrencies.join(', '),
      ),
    );
  }
  return lines;
}

class _UpcomingRenewalsSection extends StatelessWidget {
  final List<UpcomingRenewal> renewals;

  const _UpcomingRenewalsSection({required this.renewals});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(
      'MMM d',
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: context.l10n.upcomingRenewals),
        const SizedBox(height: 8),
        ...renewals.map(
          (renewal) {
            final rule = renewal.recurringExpense;
            final title =
                rule.description.isEmpty ? rule.categoryName : rule.description;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InfoRow(
                icon: Icons.event_available_outlined,
                title: title,
                subtitle: context.l10n.renewsOn(
                  dateFormat.format(renewal.dueDate),
                ),
                trailing: formatAmountWithCurrency(
                  renewal.amount,
                  renewal.currency,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PriceChangeCandidatesSection extends StatelessWidget {
  final List<SubscriptionPriceChangeCandidate> candidates;

  const _PriceChangeCandidatesSection({required this.candidates});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: context.l10n.possiblePriceChanges),
        const SizedBox(height: 8),
        ...candidates.map(
          (candidate) {
            final rule = candidate.currentRule;
            final title =
                rule.description.isEmpty ? rule.categoryName : rule.description;
            final previous = formatAmountWithCurrency(
              candidate.previousAmount,
              rule.currency,
            );
            final current = formatAmountWithCurrency(
              candidate.currentAmount,
              rule.currency,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InfoRow(
                icon: Icons.trending_up_outlined,
                title: title,
                subtitle: context.l10n.possiblePriceIncrease(previous, current),
                trailing: context.l10n.cautiousSignal,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              trailing,
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaveatText extends StatelessWidget {
  final SubscriptionCaveat caveat;

  const _CaveatText({required this.caveat});

  @override
  Widget build(BuildContext context) {
    final text = switch (caveat.type) {
      SubscriptionCaveatType.estimatedDailyImpact =>
        context.l10n.dailyMonthlyImpactEstimateCaveat,
      SubscriptionCaveatType.estimatedWeeklyImpact =>
        context.l10n.weeklyMonthlyImpactEstimateCaveat,
      SubscriptionCaveatType.mixedCurrencies =>
        context.l10n.subscriptionMixedCurrencyCaveat,
    };

    return _InfoText(text: text);
  }
}

class _InfoText extends StatelessWidget {
  final String text;

  const _InfoText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final SubscriptionSummary summary;
  final VoidCallback onEdit;

  const _SubscriptionTile({
    required this.summary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final rule = summary.recurringExpense;
    final title =
        rule.description.isEmpty ? rule.categoryName : rule.description;
    final dateFormat = DateFormat(
      'MMM d, yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    );
    final frequency = localizedRecurringFrequency(context.l10n, rule.frequency);
    final paymentMethod = localizedPaymentMethod(
      context.l10n,
      rule.paymentMethod,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CategoryIconView(
          iconKey: rule.categoryIcon,
          backgroundColor: Color(rule.categoryColor),
          size: 44,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          context.l10n.subscriptionNextDue(
            frequency,
            paymentMethod,
            dateFormat.format(summary.nextDueDate),
          ),
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatAmountWithCurrency(rule.amount, rule.currency),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  context.l10n.monthlyImpactSuffix(
                    formatAmountWithCurrency(
                      summary.monthlyImpact,
                      rule.currency,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            IconButton(
              tooltip: context.l10n.edit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySubscriptions extends StatelessWidget {
  final VoidCallback onManage;

  const _EmptySubscriptions({required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.subscriptions_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              context.l10n.noActiveSubscriptionsYet,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onManage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.manageRecurringExpenses),
            ),
          ],
        ),
      ),
    );
  }
}
