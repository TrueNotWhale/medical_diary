/// Service that manages medical norm references using a standalone in-memory structure
/// (Replaces realm to avoid code-generation and RealmObject constructor issues).
class NormReference {
  final String markerId;
  final String name;
  final String unit;
  final double? normMinMale;
  final double? normMaxMale;
  final double? normMinFemale;
  final double? normMaxFemale;
  final String description;

  const NormReference(
    this.markerId, {
    this.name = '',
    this.unit = '',
    this.normMinMale,
    this.normMaxMale,
    this.normMinFemale,
    this.normMaxFemale,
    this.description = '',
  });
}

class RealmService {
  late List<NormReference> _norms;

  Future<void> init() async {
    _seedNorms();
  }

  void _seedNorms() {
    _norms = [
      const NormReference('hemoglobin',
          name: 'Гемоглобин',
          unit: 'г/л',
          normMinMale: 130,
          normMaxMale: 170,
          normMinFemale: 120,
          normMaxFemale: 160,
          description: 'Белок эритроцитов, переносящий кислород'),
      const NormReference('leukocytes',
          name: 'Лейкоциты',
          unit: '*10^9/л',
          normMinMale: 4.0,
          normMaxMale: 9.0,
          normMinFemale: 4.0,
          normMaxFemale: 9.0,
          description: 'Клетки иммунной системы'),
      const NormReference('erythrocytes',
          name: 'Эритроциты',
          unit: '*10^12/л',
          normMinMale: 4.5,
          normMaxMale: 5.5,
          normMinFemale: 3.8,
          normMaxFemale: 5.1,
          description: 'Красные кровяные тельца'),
      const NormReference('platelets',
          name: 'Тромбоциты',
          unit: '*10^9/л',
          normMinMale: 150,
          normMaxMale: 400,
          normMinFemale: 150,
          normMaxFemale: 400,
          description: 'Клетки, участвующие в свертывании крови'),
      const NormReference('soe',
          name: 'СОЭ',
          unit: 'мм/ч',
          normMinMale: 1,
          normMaxMale: 10,
          normMinFemale: 2,
          normMaxFemale: 15,
          description: 'Скорость оседания эритроцитов'),
      const NormReference('glucose',
          name: 'Глюкоза',
          unit: 'ммоль/л',
          normMinMale: 3.9,
          normMaxMale: 6.1,
          normMinFemale: 3.9,
          normMaxFemale: 6.1,
          description: 'Уровень сахара в крови'),
      const NormReference('cholesterol',
          name: 'Холестерин',
          unit: 'ммоль/л',
          normMinMale: 0,
          normMaxMale: 5.2,
          normMinFemale: 0,
          normMaxFemale: 5.2,
          description: 'Общий холестерин'),
    ];
  }

  NormReference? getNorm(String markerId) {
    try {
      return _norms.firstWhere((n) => n.markerId == markerId);
    } catch (e) {
      return null;
    }
  }

  List<NormReference> getAllNorms() => _norms;

  void dispose() {}
}
