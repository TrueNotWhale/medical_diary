import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/analysis_model.dart';
import '../models/activity_model.dart';
import '../models/symptom_model.dart';

class HealthSnapshot {
  final List<MarkerModel> markers;
  final ActivityModel? latestActivity;
  final List<SymptomModel> symptoms;
  final int abnormalCount;
  final double healthScore;

  const HealthSnapshot({
    required this.markers,
    this.latestActivity,
    this.symptoms = const [],
    required this.abnormalCount,
    required this.healthScore,
  });
}

class HealthPipeline {
  final _markerController = BehaviorSubject<List<MarkerModel>>.seeded([]);
  final _activityController = BehaviorSubject<ActivityModel?>.seeded(null);
  final _symptomController = BehaviorSubject<List<SymptomModel>>.seeded([]);

  late final Stream<HealthSnapshot> snapshotStream;

  HealthPipeline() {
    snapshotStream = Rx.combineLatest3<List<MarkerModel>, ActivityModel?, List<SymptomModel>, HealthSnapshot>(
      _markerController.stream,
      _activityController.stream,
      _symptomController.stream,
      (markers, activity, symptoms) {
        final abnormal = markers.where((m) => m.isOutOfNorm).length;
        return HealthSnapshot(
          markers: markers,
          latestActivity: activity,
          symptoms: symptoms,
          abnormalCount: abnormal,
          healthScore: calculateScore(markers, activity, symptoms),
        );
      },
    ).asBroadcastStream();
  }

  static double calculateScore(List<MarkerModel> markers, ActivityModel? activity, List<SymptomModel> symptoms) {
    final abnormal = markers.where((m) => m.isOutOfNorm).length;
    
    // Markers: 50%
    final markerScore = markers.isEmpty
        ? 50.0
        : ((markers.length - abnormal) / markers.length * 50);

    // Activity: 30%
    final activityScore = activity != null
        ? (activity.steps >= 8000 ? 30.0 : activity.steps / 8000 * 30)
        : 15.0;

    // Symptoms: 20% (deduct points for severe symptoms)
    double symptomScore = 20.0;
    for (final s in symptoms) {
      symptomScore -= s.severity; // deduct 1-5 points per symptom
    }
    if (symptomScore < 0) symptomScore = 0;

    return (markerScore + activityScore + symptomScore).clamp(0.0, 100.0);
  }

  void updateMarkers(List<MarkerModel> markers) => _markerController.add(markers);
  void updateActivity(ActivityModel activity) => _activityController.add(activity);
  void updateSymptoms(List<SymptomModel> symptoms) => _symptomController.add(symptoms);

  void dispose() {
    _markerController.close();
    _activityController.close();
    _symptomController.close();
  }
}
