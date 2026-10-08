class AnalysisModel {
  final int? id;
  final String labName;
  final DateTime date;
  final List<MarkerModel> markers;

  const AnalysisModel({
    this.id,
    required this.labName,
    required this.date,
    required this.markers,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'labName': labName,
        'date': date.toIso8601String(),
      };

  factory AnalysisModel.fromMap(Map<String, dynamic> map) => AnalysisModel(
        id: map['id'] as int?,
        labName: map['labName'] as String,
        date: DateTime.parse(map['date'] as String),
        markers: [],
      );
}

class MarkerModel {
  final int? id;
  final int analysisId;
  final String name;
  final double value;
  final String unit;
  final double? normMin;
  final double? normMax;

  const MarkerModel({
    this.id,
    required this.analysisId,
    required this.name,
    required this.value,
    required this.unit,
    this.normMin,
    this.normMax,
  });

  bool get isAboveNorm => normMax != null && value > normMax!;
  bool get isBelowNorm => normMin != null && value < normMin!;
  bool get isOutOfNorm => isAboveNorm || isBelowNorm;

  Map<String, dynamic> toMap() => {
        'id': id,
        'analysisId': analysisId,
        'name': name,
        'value': value,
        'unit': unit,
        'normMin': normMin,
        'normMax': normMax,
      };

  factory MarkerModel.fromMap(Map<String, dynamic> map) => MarkerModel(
        id: map['id'] as int?,
        analysisId: map['analysisId'] as int,
        name: map['name'] as String,
        value: (map['value'] as num).toDouble(),
        unit: map['unit'] as String,
        normMin: map['normMin'] != null ? (map['normMin'] as num).toDouble() : null,
        normMax: map['normMax'] != null ? (map['normMax'] as num).toDouble() : null,
      );
}
