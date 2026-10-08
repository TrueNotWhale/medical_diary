import 'package:realm/realm.dart';

/// NormReference stores medical reference ranges for blood markers.
/// Written without code-generation (no part directive / @RealmModel annotation).
/// The schema is registered manually via [NormReference.schema].
class NormReference extends RealmObject {
  NormReference(
    String markerId, {
    String name = '',
    String unit = '',
    double? normMinMale,
    double? normMaxMale,
    double? normMinFemale,
    double? normMaxFemale,
    String description = '',
  }) {
    RealmObjectBase.set(this, 'markerId', markerId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'normMinMale', normMinMale);
    RealmObjectBase.set(this, 'normMaxMale', normMaxMale);
    RealmObjectBase.set(this, 'normMinFemale', normMinFemale);
    RealmObjectBase.set(this, 'normMaxFemale', normMaxFemale);
    RealmObjectBase.set(this, 'description', description);
  }

  NormReference._();

  String get markerId =>
      RealmObjectBase.get<String>(this, 'markerId') as String;
  set markerId(String value) =>
      RealmObjectBase.set(this, 'markerId', value);

  String get name =>
      RealmObjectBase.get<String>(this, 'name') as String;
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  String get unit =>
      RealmObjectBase.get<String>(this, 'unit') as String;
  set unit(String value) => RealmObjectBase.set(this, 'unit', value);

  double? get normMinMale =>
      RealmObjectBase.get<double>(this, 'normMinMale') as double?;
  set normMinMale(double? value) =>
      RealmObjectBase.set(this, 'normMinMale', value);

  double? get normMaxMale =>
      RealmObjectBase.get<double>(this, 'normMaxMale') as double?;
  set normMaxMale(double? value) =>
      RealmObjectBase.set(this, 'normMaxMale', value);

  double? get normMinFemale =>
      RealmObjectBase.get<double>(this, 'normMinFemale') as double?;
  set normMinFemale(double? value) =>
      RealmObjectBase.set(this, 'normMinFemale', value);

  double? get normMaxFemale =>
      RealmObjectBase.get<double>(this, 'normMaxFemale') as double?;
  set normMaxFemale(double? value) =>
      RealmObjectBase.set(this, 'normMaxFemale', value);

  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  // ── Manual schema definition ──────────────────────────────────────────────
  static SchemaObject get schema => const SchemaObject(
        ObjectType.realmObject,
        NormReference,
        'NormReference',
        [
          SchemaProperty('markerId', RealmPropertyType.string,
              primaryKey: true),
          SchemaProperty('name', RealmPropertyType.string),
          SchemaProperty('unit', RealmPropertyType.string),
          SchemaProperty('normMinMale', RealmPropertyType.double,
              optional: true),
          SchemaProperty('normMaxMale', RealmPropertyType.double,
              optional: true),
          SchemaProperty('normMinFemale', RealmPropertyType.double,
              optional: true),
          SchemaProperty('normMaxFemale', RealmPropertyType.double,
              optional: true),
          SchemaProperty('description', RealmPropertyType.string),
        ],
      );
}

/// Service that manages the Realm database for medical norm references.
class RealmService {
  late Realm _realm;

  Future<void> init() async {
    final config = Configuration.local(
      [NormReference.schema],
      schemaVersion: 1,
    );
    _realm = Realm(config);
    _seedNorms();
  }

  void _seedNorms() {
    if (_realm.all<NormReference>().isNotEmpty) return;
    _realm.write(() {
      final norms = [
        NormReference('hemoglobin',
            name: 'Гемоглобин',
            unit: 'г/л',
            normMinMale: 130,
            normMaxMale: 170,
            normMinFemale: 120,
            normMaxFemale: 160,
            description: 'Белок эритроцитов, переносящий кислород'),
        NormReference('leukocytes',
            name: 'Лейкоциты',
            unit: '*10^9/л',
            normMinMale: 4.0,
            normMaxMale: 9.0,
            normMinFemale: 4.0,
            normMaxFemale: 9.0,
            description: 'Клетки иммунной системы'),
        NormReference('erythrocytes',
            name: 'Эритроциты',
            unit: '*10^12/л',
            normMinMale: 4.5,
            normMaxMale: 5.5,
            normMinFemale: 3.8,
            normMaxFemale: 5.1,
            description: 'Красные кровяные тельца'),
        NormReference('platelets',
            name: 'Тромбоциты',
            unit: '*10^9/л',
            normMinMale: 150,
            normMaxMale: 400,
            normMinFemale: 150,
            normMaxFemale: 400,
            description: 'Клетки, участвующие в свертывании крови'),
        NormReference('soe',
            name: 'СОЭ',
            unit: 'мм/ч',
            normMinMale: 1,
            normMaxMale: 10,
            normMinFemale: 2,
            normMaxFemale: 15,
            description: 'Скорость оседания эритроцитов'),
        NormReference('glucose',
            name: 'Глюкоза',
            unit: 'ммоль/л',
            normMinMale: 3.9,
            normMaxMale: 6.1,
            normMinFemale: 3.9,
            normMaxFemale: 6.1,
            description: 'Уровень сахара в крови'),
        NormReference('cholesterol',
            name: 'Холестерин',
            unit: 'ммоль/л',
            normMinMale: 0,
            normMaxMale: 5.2,
            normMinFemale: 0,
            normMaxFemale: 5.2,
            description: 'Общий холестерин'),
      ];
      _realm.addAll(norms);
    });
  }

  NormReference? getNorm(String markerId) =>
      _realm.find<NormReference>(markerId);

  List<NormReference> getAllNorms() =>
      _realm.all<NormReference>().toList();

  void dispose() => _realm.close();
}
