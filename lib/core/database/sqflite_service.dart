import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/symptom_model.dart';
import '../models/analysis_model.dart';
import '../models/activity_model.dart';

class SqfliteService {
  static Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'medical_diary.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Database get db => _db!;

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        severity INTEGER NOT NULL,
        notes TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        labName TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE markers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        analysisId INTEGER NOT NULL,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        normMin REAL,
        normMax REAL,
        FOREIGN KEY (analysisId) REFERENCES analyses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps INTEGER NOT NULL,
        pulse INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Seed demo data
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    // Seed symptoms
    for (int i = 6; i >= 0; i--) {
      await db.insert('symptoms', {
        'name': i % 2 == 0 ? 'Головная боль' : 'Усталость',
        'severity': 1 + (i % 5),
        'notes': 'Умеренная интенсивность',
        'timestamp': now.subtract(Duration(days: i)).toIso8601String(),
      });
    }
    // Seed activity
    for (int i = 6; i >= 0; i--) {
      await db.insert('activity', {
        'steps': 4000 + (i * 700),
        'pulse': 68 + (i % 10),
        'timestamp': now.subtract(Duration(days: i)).toIso8601String(),
      });
    }
  }

  // ── Symptoms CRUD ──────────────────────────────────────────────────────────

  Future<int> insertSymptom(SymptomModel s) =>
      db.insert('symptoms', s.toMap()..remove('id'));

  Future<List<SymptomModel>> getSymptoms() async {
    final rows = await db.query('symptoms', orderBy: 'timestamp DESC');
    return rows.map(SymptomModel.fromMap).toList();
  }

  // ── Analyses CRUD ──────────────────────────────────────────────────────────

  Future<int> insertAnalysis(AnalysisModel a) async {
    final id = await db.insert('analyses', a.toMap()..remove('id'));
    for (final m in a.markers) {
      final markerMap = m.toMap();
      markerMap['analysisId'] = id;
      markerMap.remove('id');
      await db.insert('markers', markerMap);
    }
    return id;
  }

  Future<List<AnalysisModel>> getAnalyses() async {
    final rows = await db.query('analyses', orderBy: 'date DESC');
    final analyses = <AnalysisModel>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final markerRows = await db.query(
        'markers',
        where: 'analysisId = ?',
        whereArgs: [id],
      );
      final markers = markerRows.map(MarkerModel.fromMap).toList();
      analyses.add(AnalysisModel(
        id: id,
        labName: row['labName'] as String,
        date: DateTime.parse(row['date'] as String),
        markers: markers,
      ));
    }
    return analyses;
  }

  Future<AnalysisModel?> getAnalysisById(int id) async {
    final rows =
        await db.query('analyses', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final markerRows =
        await db.query('markers', where: 'analysisId = ?', whereArgs: [id]);
    return AnalysisModel(
      id: id,
      labName: rows.first['labName'] as String,
      date: DateTime.parse(rows.first['date'] as String),
      markers: markerRows.map(MarkerModel.fromMap).toList(),
    );
  }

  // ── Activity CRUD ──────────────────────────────────────────────────────────

  Future<int> insertActivity(ActivityModel a) =>
      db.insert('activity', a.toMap()..remove('id'));

  Future<List<ActivityModel>> getActivity({int limit = 7}) async {
    final rows = await db.query(
      'activity',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(ActivityModel.fromMap).toList();
  }
}
