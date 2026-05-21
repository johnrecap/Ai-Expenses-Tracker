import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/saving_goals/blocs/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expenses_tracker/screens/saving_goals/widgets/saving_goal_card.dart';
import 'package:expenses_tracker/screens/saving_goals/widgets/saving_goal_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  State<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  List<String> _currencies = const ['EGP', 'USD'];

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    SettingsRepository? settingsRepository;
    try {
      settingsRepository = context.read<SettingsRepository>();
    } catch (_) {
      settingsRepository = null;
    }

    if (settingsRepository == null) return;
    try {
      final settings = await settingsRepository.getSettings();
      if (!mounted || settings.supportedCurrencies.isEmpty) return;
      setState(() {
        _currencies = settings.supportedCurrencies;
      });
    } catch (_) {
      // Settings should not block saving goal management.
    }
  }

  Future<void> _showForm({SavingGoal? initialGoal}) async {
    final goal = await showDialog<SavingGoal>(
      context: context,
      builder: (_) => SavingGoalForm(
        currencies: _currencies,
        initialGoal: initialGoal,
      ),
    );
    if (goal == null || !mounted) return;

    final bloc = context.read<SavingGoalBloc>();
    if (initialGoal == null) {
      bloc.add(SavingGoalCreateRequested(goal));
    } else {
      bloc.add(SavingGoalUpdateRequested(goal));
    }
  }

  Future<void> _showContributionDialog(SavingGoal goal) async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.addContributionToGoal(goal.name)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: dialogContext.l10n.contributionAmount,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  double.tryParse(controller.text.trim()) ?? 0,
                );
              },
              child: Text(dialogContext.l10n.add),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (amount == null || !mounted) return;
    context.read<SavingGoalBloc>().add(
          SavingGoalContributionRequested(goal: goal, amount: amount),
        );
  }

  Future<void> _confirmArchive(SavingGoal goal) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.archiveSavingGoal),
          content: Text(dialogContext.l10n.archiveSavingGoalMessage(goal.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.l10n.archive),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true || !mounted) return;
    context.read<SavingGoalBloc>().add(SavingGoalArchiveRequested(goal));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavingGoalBloc, SavingGoalState>(
      listener: (context, state) {
        if (state is SavingGoalFailure) {
          _showMessage(state.message);
        } else if (state is SavingGoalActionSuccess) {
          _showMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(context.l10n.savingGoalsTitle),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<SavingGoalBloc, SavingGoalState>(
          builder: (context, state) {
            if (state is SavingGoalLoading || state is SavingGoalSaving) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SavingGoalFailure) {
              return _SavingGoalError(
                message: state.message,
                onRetry: () => context.read<SavingGoalBloc>().add(
                      const SavingGoalsWatchRequested(),
                    ),
              );
            }

            final goals = state is SavingGoalSuccess
                ? state.goals.where((goal) => !goal.isArchived).toList()
                : <SavingGoal>[];

            if (goals.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.noActiveSavingGoalsYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadCurrencies,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return SavingGoalCard(
                    goal: goal,
                    onEdit: () => _showForm(initialGoal: goal),
                    onContribute: () => _showContributionDialog(goal),
                    onArchive: () => _confirmArchive(goal),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavingGoalError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SavingGoalError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
