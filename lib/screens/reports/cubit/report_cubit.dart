import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final List<Expense> _expenses;
  final UserSettings _settings;

  ReportCubit({
    required List<Expense> expenses,
    required UserSettings settings,
  })  : _expenses = List.unmodifiable(expenses),
        _settings = settings,
        super(ReportInitial());

  void loadWeekly() {
    _load(ReportRange.weekly(), ReportRangeType.weekly);
  }

  void loadMonthly() {
    _load(ReportRange.monthly(), ReportRangeType.monthly);
  }

  void _load(ReportRange range, ReportRangeType selectedRange) {
    emit(ReportLoading());
    try {
      final report = ReportCalculator.calculate(
        expenses: _expenses,
        range: range,
        settings: _settings,
      );
      if (report.total == 0 && report.categoryTotals.isEmpty) {
        emit(ReportEmpty(report: report, selectedRange: selectedRange));
        return;
      }
      emit(ReportLoaded(report: report, selectedRange: selectedRange));
    } catch (_) {
      emit(const ReportFailure('Failed to load report.'));
    }
  }
}
