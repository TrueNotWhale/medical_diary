part of 'scanner_cubit.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerIdle extends ScannerState {}

class ScannerProcessing extends ScannerState {}

class ScannerResult extends ScannerState {
  final List<MarkerModel> markers;
  final String rawText;
  const ScannerResult({required this.markers, required this.rawText});
  @override
  List<Object?> get props => [markers, rawText];
}

class ScannerSaved extends ScannerState {}

class ScannerError extends ScannerState {
  final String message;
  const ScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
