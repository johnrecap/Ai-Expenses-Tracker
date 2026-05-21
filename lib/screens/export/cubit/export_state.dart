part of 'export_cubit.dart';

sealed class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

final class ExportInitial extends ExportState {
  const ExportInitial();
}

final class ExportLoading extends ExportState {
  const ExportLoading();
}

final class ExportSuccess extends ExportState {
  const ExportSuccess(this.result);

  final ExportResult result;

  @override
  List<Object?> get props =>
      [result.fileName, result.path, result.bytes.length];
}

final class ExportFailure extends ExportState {
  const ExportFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
