import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';

part 'create_expense_event.dart';
part 'create_expense_state.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  final ExpenseRepository expenseRepository;
  final BudgetRepository? budgetRepository;
  final SettingsRepository? settingsRepository;
  final NotificationScheduler? notificationScheduler;

  CreateExpenseBloc(
    this.expenseRepository, {
    this.budgetRepository,
    this.settingsRepository,
    this.notificationScheduler,
  }) : super(CreateExpenseInitial()) {
    on<CreateExpense>((event, emit) async {
      emit(CreateExpenseLoading());
      try {
        await expenseRepository.createExpense(event.expense);
        try {
          await _handleNotifications(event.expense);
        } catch (_) {
          // Notification failures must not roll back a saved expense.
        }
        emit(CreateExpenseSuccess());
      } catch (e) {
        emit(CreateExpenseFailure());
      }
    });
  }

  Future<void> _handleNotifications(Expense expense) async {
    final budgetRepository = this.budgetRepository;
    final settingsRepository = this.settingsRepository;
    final scheduler = notificationScheduler;
    if (budgetRepository == null ||
        settingsRepository == null ||
        scheduler == null) {
      return;
    }

    await scheduler.handleExpenseCreated(
      expense: expense,
      expenseRepository: expenseRepository,
      budgetRepository: budgetRepository,
      settingsRepository: settingsRepository,
    );
  }
}
