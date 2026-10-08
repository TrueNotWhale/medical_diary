part of 'symptom_cubit.dart';

abstract class SymptomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SymptomLoading extends SymptomState {}

class SymptomLoaded extends SymptomState {
  final List<SymptomModel> symptoms;

  SymptomLoaded(this.symptoms);

  @override
  List<Object?> get props => [symptoms];
}

class SymptomError extends SymptomState {
  final String message;

  SymptomError(this.message);

  @override
  List<Object?> get props => [message];
}
