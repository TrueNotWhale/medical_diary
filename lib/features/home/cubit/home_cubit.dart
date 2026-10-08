import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/sqflite_service.dart';
import '../../../core/models/symptom_model.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/models/activity_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SqfliteService _db;

  HomeCubit(this._db) : super(HomeLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(HomeLoading());
    try {
      final symptoms = await _db.getSymptoms();
      final analyses = await _db.getAnalyses();
      final activity = await _db.getActivity();
      emit(HomeLoaded(
        allSymptoms: symptoms,
        recentSymptoms: symptoms.take(3).toList(),
        analyses: analyses,
        activityData: activity,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
