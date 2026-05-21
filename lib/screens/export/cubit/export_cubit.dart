import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/export/export.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  ExportCubit({
    required ExportService exportService,
    ExportFileSharer fileSharer = const LocalExportFileSharer(),
  })  : _exportService = exportService,
        _fileSharer = fileSharer,
        super(const ExportInitial());

  final ExportService _exportService;
  final ExportFileSharer _fileSharer;

  Future<void> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  }) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      emit(ExportFailure(errors.join(' ')));
      return;
    }

    emit(const ExportLoading());
    try {
      final generated = await _exportService.exportExpenses(
        expenses: expenses,
        request: request,
      );
      final path = await _fileSharer.save(generated);
      emit(
        ExportSuccess(
          ExportResult(
            fileName: generated.fileName,
            mimeType: generated.mimeType,
            bytes: generated.bytes,
            path: path,
          ),
        ),
      );
    } catch (error) {
      emit(ExportFailure(error.toString()));
    }
  }

  Future<void> share(ExportResult result) async {
    try {
      await _fileSharer.share(result);
    } catch (error) {
      emit(ExportFailure(error.toString()));
    }
  }
}
