part of 'activity_cubit.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
  @override
  List<Object?> get props => [];
}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityModel> activityList;
  final HealthSnapshot snapshot;

  const ActivityLoaded({required this.activityList, required this.snapshot});

  @override
  List<Object?> get props => [activityList, snapshot];
}

class ActivityError extends ActivityState {
  final String message;
  const ActivityError(this.message);
  @override
  List<Object?> get props => [message];
}
