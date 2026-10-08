part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SymptomModel> recentSymptoms;
  final List<AnalysisModel> analyses;
  final List<ActivityModel> activityData;

  HomeLoaded({
    required this.recentSymptoms,
    required this.analyses,
    required this.activityData,
  });

  @override
  List<Object?> get props => [recentSymptoms, analyses, activityData];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
