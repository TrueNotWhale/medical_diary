import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/sqflite_service.dart';
import '../../../core/database/realm_service.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/ocr/ocr_parser.dart';

part 'scanner_state.dart';

/// Mock OCR text simulating a CBC (ОАК) lab report.
const _mockOcrText = '''
Результат общего анализа крови
Гемоглобин 185 г/л
Лейкоциты 11.5 *10^9/л
Эритроциты 5.2 *10^12/л
Тромбоциты 220 *10^9/л
СОЭ 18 мм/ч
Глюкоза 5.4 ммоль/л
Холестерин 6.1 ммоль/л
''';

class ScannerCubit extends Cubit<ScannerState> {
  final SqfliteService _db;
  final RealmService _realm;

  ScannerCubit(this._db, this._realm) : super(ScannerIdle());

  /// Simulates OCR scanning by parsing the mock CBC text.
  Future<void> scanMock({bool isMale = true}) async {
    emit(ScannerProcessing());
    await Future.delayed(const Duration(seconds: 2));
    try {
      final parser = OcrParser(_realm);
      final markers = parser.parse(_mockOcrText, isMale: isMale);
      emit(ScannerResult(markers: markers, rawText: _mockOcrText));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  /// Persists the parsed markers as an analysis record in SQLite.
  Future<void> saveResult({
      required String labName, required List<MarkerModel> markers}) async {
    try {
      final analysis = AnalysisModel(
        labName: labName,
        date: DateTime.now(),
        markers: markers,
      );
      await _db.insertAnalysis(analysis);
      emit(ScannerIdle());
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  void reset() => emit(ScannerIdle());
}
