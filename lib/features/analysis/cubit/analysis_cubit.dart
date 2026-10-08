import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/sqflite_service.dart';
import '../../../core/models/analysis_model.dart';

part 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  final SqfliteService _db;
  final dynamic _realmService;

  AnalysisCubit(this._db, this._realmService) : super(AnalysisLoading());

  Future<void> loadAnalysis(int id) async {
    emit(AnalysisLoading());
    try {
      final analysis = await _db.getAnalysisById(id);
      if (analysis == null) {
        emit(const AnalysisError('Анализ не найден'));
      } else {
        emit(AnalysisLoaded(analysis));
      }
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }
}
