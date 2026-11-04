import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/savings_goal.dart';
import '../models/saving_entry.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'save40.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            target_paise INTEGER NOT NULL,
            duration_days INTEGER NOT NULL,
            start_date TEXT NOT NULL,
            saving_mode TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER NOT NULL,
            day_number INTEGER NOT NULL,
            entry_date TEXT NOT NULL,
            amount_paise INTEGER NOT NULL,
            note TEXT,
            UNIQUE(goal_id, day_number),
            FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    await _database!.execute('PRAGMA foreign_keys = ON');
    return _database!;
  }

  Future<int> createGoal(SavingsGoal goal) async {
    final db = await database;
    return db.insert('goals', goal.toMap());
  }

  Future<List<SavingsGoal>> getGoals() async {
    final db = await database;
    final rows = await db.query('goals', orderBy: 'created_at DESC');
    return rows.map(SavingsGoal.fromMap).toList();
  }

  Future<void> deleteGoal(int id) async {
    final db = await database;
    await db.delete('entries', where: 'goal_id = ?', whereArgs: [id]);
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SavingEntry>> getEntries(int goalId) async {
    final db = await database;
    final rows = await db.query(
      'entries',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'day_number ASC',
    );
    return rows.map(SavingEntry.fromMap).toList();
  }
  Future<Map<int, int>> getAllGoalTotals() async {
    final db = await database;

    final rows = await db.rawQuery('''
      SELECT
        goal_id,
        COALESCE(SUM(amount_paise), 0) AS total_saved
      FROM entries
      GROUP BY goal_id
    ''');

    return {
      for (final row in rows)
        row['goal_id'] as int: (row['total_saved'] as num).toInt(),
    };
  }
  
  Future<void> saveEntry(SavingEntry entry) async {
    final db = await database;
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntry(int goalId, int dayNumber) async {
    final db = await database;
    await db.delete(
      'entries',
      where: 'goal_id = ? AND day_number = ?',
      whereArgs: [goalId, dayNumber],
    );
  }
}
