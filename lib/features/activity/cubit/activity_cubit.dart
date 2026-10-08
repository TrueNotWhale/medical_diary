import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/sqflite_service.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/streams/health_pipeline.dart';

part 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final SqfliteService _db;
  late final HealthPipeline _pipeline;
  StreamSubscription<HealthSnapshot>? _subscription;

  ActivityCubit(this._db) : super(ActivityLoading()) {
    _pipeline = HealthPipeline();
    _init();
  }

  Future<void> _init() async {
    emit(ActivityLoading());
    try {
      final activityList = await _db.getActivity(limit: 14);
      final analyses = await _db.getAnalyses();
      final symptoms = await _db.getSymptoms();

      // Feed data into the reactive pipeline
      if (activityList.isNotEmpty) {
        _pipeline.updateActivity(activityList.first);
      }
      if (analyses.isNotEmpty) {
        _pipeline.updateMarkers(analyses.first.markers);
      }
      if (symptoms.isNotEmpty) {
        _pipeline.updateSymptoms(symptoms);
      }

      // Subscribe to the combined health snapshot stream
      _subscription = _pipeline.snapshotStream.listen((snapshot) {
        if (!isClosed) {
          emit(ActivityLoaded(
            activityList: activityList,
            snapshot: snapshot,
          ));
        }
      });

      emit(ActivityLoaded(
        activityList: activityList,
        snapshot: HealthSnapshot(
          markers: analyses.isNotEmpty ? analyses.first.markers : const [],
          latestActivity: activityList.isNotEmpty ? activityList.first : null,
          symptoms: symptoms,
          abnormalCount: analyses.isNotEmpty ? analyses.first.markers.where((m) => m.isOutOfNorm).length : 0,
          healthScore: HealthPipeline.calculateScore(
            analyses.isNotEmpty ? analyses.first.markers : const [],
            activityList.isNotEmpty ? activityList.first : null,
            symptoms,
          ),
        ),
      ));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  /// Add a manual activity entry and update the reactive pipeline
  Future<void> addActivity({required int steps, required int pulse}) async {
    final activity = ActivityModel(
      steps: steps,
      pulse: pulse,
      timestamp: DateTime.now(),
    );
    await _db.insertActivity(activity);
    _pipeline.updateActivity(activity);
    await _init();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _pipeline.dispose();
    return super.close();
  }
}
