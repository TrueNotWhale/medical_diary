import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/sqflite_service.dart';
import '../../../core/models/symptom_model.dart';

part 'symptom_state.dart';

class SymptomCubit extends Cubit<SymptomState> {
  final SqfliteService _db;

  SymptomCubit(this._db) : super(SymptomLoading()) {
    loadSymptoms();
  }

  Future<void> loadSymptoms() async {
    emit(SymptomLoading());
    try {
      final symptoms = await _db.getSymptoms();
      emit(SymptomLoaded(symptoms));
    } catch (e) {
      emit(SymptomError(e.toString()));
    }
  }

  Future<void> addSymptom({
    required String name,
    required int severity,
    required String notes,
  }) async {
    try {
      final symptom = SymptomModel(
        name: name,
        severity: severity,
        notes: notes,
        timestamp: DateTime.now(),
      );
      await _db.insertSymptom(symptom);
      await loadSymptoms();
    } catch (e) {
      emit(SymptomError(e.toString()));
    }
  }
}
