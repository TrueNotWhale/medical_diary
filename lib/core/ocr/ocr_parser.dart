import '../models/analysis_model.dart';
import '../database/realm_service.dart';

/// Parser that extracts blood marker values from OCR text using regex.
/// Supports tabular format: marker_name ... value ... unit ... norm
class OcrParser {
  final RealmService _realmService;

  OcrParser(this._realmService);

  // Mapping of recognised text keywords to Realm marker IDs
  static const Map<String, String> _keywordToId = {
    'гемоглобин': 'hemoglobin',
    'hemoglobin': 'hemoglobin',
    'лейкоциты': 'leukocytes',
    'leukocytes': 'leukocytes',
    'эритроциты': 'erythrocytes',
    'erythrocytes': 'erythrocytes',
    'тромбоциты': 'platelets',
    'platelets': 'platelets',
    'соэ': 'soe',
    'esr': 'soe',
    'глюкоза': 'glucose',
    'glucose': 'glucose',
    'холестерин': 'cholesterol',
    'cholesterol': 'cholesterol',
  };

  /// Main entry point: parse raw OCR text and return list of recognised markers.
  ///
  /// Algorithm:
  /// 1. Split text into lines.
  /// 2. For each line, try to find a known marker keyword (case-insensitive).
  /// 3. Extract the numeric value using regex (first float/int in the line).
  /// 4. Look up unit from remaining text.
  /// 5. Load norm reference from Realm and annotate min/max.
  List<MarkerModel> parse(String rawText, {bool isMale = true}) {
    final lines = rawText.split('\n');
    final result = <MarkerModel>[];
    final numRegex = RegExp(r'(\d+[,.]?\d*)');

    for (final line in lines) {
      final lower = line.toLowerCase();
      String? matchedId;
      String? matchedName;

      // Step 2: keyword scan
      for (final entry in _keywordToId.entries) {
        if (lower.contains(entry.key)) {
          matchedId = entry.value;
          matchedName = entry.key;
          break;
        }
      }
      if (matchedId == null) continue;

      // Step 3: extract first numeric value in line
      final numMatches = numRegex.allMatches(line).toList();
      if (numMatches.isEmpty) continue;
      final rawValue =
          numMatches.first.group(1)!.replaceAll(',', '.');
      final value = double.tryParse(rawValue);
      if (value == null) continue;

      // Step 4: extract unit (look for known unit tokens)
      String unit = '';
      final unitPatterns = [
        'г/л',
        'мм/ч',
        '*10^9/л',
        '*10^12/л',
        'ммоль/л',
        'g/l',
        'mm/h'
      ];
      for (final u in unitPatterns) {
        if (line.contains(u)) {
          unit = u;
          break;
        }
      }

      // Step 5: load norm from Realm reference
      final norm = _realmService.getNorm(matchedId);
      final normMin = isMale ? norm?.normMinMale : norm?.normMinFemale;
      final normMax = isMale ? norm?.normMaxMale : norm?.normMaxFemale;

      result.add(MarkerModel(
        analysisId: 0,
        name: norm?.name ?? matchedName!,
        value: value,
        unit: unit.isNotEmpty ? unit : (norm?.unit ?? ''),
        normMin: normMin,
        normMax: normMax,
      ));
    }

    return result;
  }
}
