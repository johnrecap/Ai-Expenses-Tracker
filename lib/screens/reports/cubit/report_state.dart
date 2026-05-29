part of 'report_cubit.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

final class ReportInitial extends ReportState {}

final class ReportLoading extends ReportState {}

final class ReportLoaded extends ReportState {
  final ExpenseReport report;
  final ReportRangeType selectedRange;

  const ReportLoaded({required this.report, required this.selectedRange});

  @override
  List<Object?> get props => [report, selectedRange];
}

final class ReportEmpty extends ReportState {
  final ExpenseReport report;
  final ReportRangeType selectedRange;

  const ReportEmpty({required this.report, required this.selectedRange});

  @override
  List<Object?> get props => [report, selectedRange];
}

final class ReportFailure extends ReportState {
  final String message;

  const ReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
