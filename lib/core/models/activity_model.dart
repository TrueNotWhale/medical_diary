class ActivityModel {
  final int? id;
  final int steps;
  final int pulse;
  final DateTime timestamp;

  const ActivityModel({
    this.id,
    required this.steps,
    required this.pulse,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'steps': steps,
        'pulse': pulse,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
        id: map['id'] as int?,
        steps: map['steps'] as int,
        pulse: map['pulse'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}
