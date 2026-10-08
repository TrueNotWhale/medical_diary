class SymptomModel {
  final int? id;
  final String name;
  final int severity; // 1-5
  final String notes;
  final DateTime timestamp;

  const SymptomModel({
    this.id,
    required this.name,
    required this.severity,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'severity': severity,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SymptomModel.fromMap(Map<String, dynamic> map) => SymptomModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        severity: map['severity'] as int,
        notes: map['notes'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  SymptomModel copyWith({
    int? id,
    String? name,
    int? severity,
    String? notes,
    DateTime? timestamp,
  }) =>
      SymptomModel(
        id: id ?? this.id,
        name: name ?? this.name,
        severity: severity ?? this.severity,
        notes: notes ?? this.notes,
        timestamp: timestamp ?? this.timestamp,
      );
}
