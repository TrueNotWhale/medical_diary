part of 'analysis_cubit.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final AnalysisModel analysis;
  const AnalysisLoaded(this.analysis);
  @override
  List<Object?> get props => [analysis];
}

class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object?> get props => [message];
}
