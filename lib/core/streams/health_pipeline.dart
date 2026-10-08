import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/analysis_model.dart';
import '../models/activity_model.dart';

/// Combined health data state emitted by the pipeline.
class HealthSnapshot {
  final List<MarkerModel> markers;
  final ActivityModel? latestActivity;
  final int abnormalCount;
  final double healthScore; // 0-100

  const HealthSnapshot({
    required this.markers,
    this.latestActivity,
    required this.abnormalCount,
    required this.healthScore,
  });
}

/// Reactive pipeline combining marker data and activity data into a
/// [HealthSnapshot] stream via RxDart combineLatest2.
///
/// Stream<List<MarkerModel>>  (from OCR / DB)
/// +
/// Stream<ActivityModel?>     (from sensor / DB)
/// ──▶ Stream<HealthSnapshot>
class HealthPipeline {
  final _markerController =
      BehaviorSubject<List<MarkerModel>>.seeded([]);
  final _activityController =
      BehaviorSubject<ActivityModel?>.seeded(null);

  late final Stream<HealthSnapshot> snapshotStream;

  HealthPipeline() {
    snapshotStream =
        Rx.combineLatest2<List<MarkerModel>, ActivityModel?, HealthSnapshot>(
      _markerController.stream,
      _activityController.stream,
      (markers, activity) {
        // Count out-of-norm markers
        final abnormal = markers.where((m) => m.isOutOfNorm).length;

        // Marker score: proportion of normal markers contributes up to 70 pts
        final markerScore = markers.isEmpty
            ? 100.0
            : ((markers.length - abnormal) / markers.length * 70);

        // Activity score: ≥ 8000 steps → full 30 pts
        final activityScore = activity != null
            ? (activity.steps >= 8000
                ? 30.0
                : activity.steps / 8000 * 30)
            : 15.0;

        return HealthSnapshot(
          markers: markers,
          latestActivity: activity,
          abnormalCount: abnormal,
          healthScore:
              (markerScore + activityScore).clamp(0.0, 100.0),
        );
      },
    ).asBroadcastStream();
  }

  void updateMarkers(List<MarkerModel> markers) =>
      _markerController.add(markers);

  void updateActivity(ActivityModel activity) =>
      _activityController.add(activity);

  void dispose() {
    _markerController.close();
    _activityController.close();
  }
}
