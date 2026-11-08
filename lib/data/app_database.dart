import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/savings_goal.dart';
import '../models/saving_entry.dart';
import '../models/vehicle.dart';
import '../models/fuel_entry.dart';

class AppDatabase {
  AppDatabase._({String? databasePath})
      : _databasePath = databasePath;

  AppDatabase.forTesting(String databasePath)
      : this._(databasePath: databasePath);

  static final AppDatabase instance = AppDatabase._();

  final String? _databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = _databasePath ??
        p.join(await getDatabasesPath(), 'save40.db');

    _database = await openDatabase(
      dbPath,
      version: 5,
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            manufacturer TEXT,
            model TEXT,
            fuel_type TEXT NOT NULL,
            nickname TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS fuel_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_id INTEGER NOT NULL,
            amount_paise INTEGER NOT NULL,
            quantity_ml INTEGER NOT NULL,
            fuel_type TEXT NOT NULL,
            refill_type TEXT NOT NULL,
            entry_date TEXT NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
          )
        ''');
        // New table for manual distance entries
        await db.execute('''
          CREATE TABLE IF NOT EXISTS distance_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_id INTEGER NOT NULL,
            distance_m INTEGER NOT NULL,
            journey_id TEXT NOT NULL,
            recorded_at TEXT NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
            UNIQUE(journey_id)
          )
        ''');
        // New table for GPS ride records
        await db.execute('''
          CREATE TABLE IF NOT EXISTS gps_rides (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_id INTEGER NOT NULL,
            distance_m INTEGER NOT NULL,
            duration_s INTEGER NOT NULL,
            journey_id TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
            UNIQUE(journey_id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS vehicles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              category TEXT NOT NULL,
              manufacturer TEXT,
              model TEXT,
              fuel_type TEXT NOT NULL,
              nickname TEXT,
              notes TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS fuel_entries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicle_id INTEGER NOT NULL,
              amount_paise INTEGER NOT NULL,
              quantity_ml INTEGER NOT NULL,
              fuel_type TEXT NOT NULL,
              refill_type TEXT NOT NULL,
              entry_date TEXT NOT NULL,
              notes TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS distance_entries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicle_id INTEGER NOT NULL,
              distance_m INTEGER NOT NULL,
              journey_id TEXT NOT NULL,
              recorded_at TEXT NOT NULL,
              notes TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
              UNIQUE(journey_id)
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS gps_rides (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicle_id INTEGER NOT NULL,
              distance_m INTEGER NOT NULL,
              duration_s INTEGER NOT NULL,
              journey_id TEXT NOT NULL,
              start_time TEXT NOT NULL,
              end_time TEXT NOT NULL,
              notes TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
              UNIQUE(journey_id)
            )
          ''');
        }
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

  void _validateVehicle(Vehicle vehicle) {
    final error = vehicle.validate();
    if (error != null) {
      throw ArgumentError(error);
    }
  }

  Future<int> createVehicle(Vehicle vehicle) async {
    _validateVehicle(vehicle);
    final db = await database;
    return db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final rows = await db.query(
      'vehicles',
      orderBy: 'created_at DESC',
    );
    return rows.map(Vehicle.fromMap).toList();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    final db = await database;
    final rows = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Vehicle.fromMap(rows.first);
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) {
      throw ArgumentError('Vehicle ID is required for update');
    }

    _validateVehicle(vehicle);
    final db = await database;

    return db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  void _validateFuelEntry(FuelEntry entry) {
    final error = entry.validate();
    if (error != null) {
      throw ArgumentError(error);
    }
  }

  Future<int> createFuelEntry(FuelEntry entry) async {
    _validateFuelEntry(entry);
    final db = await database;
    return db.insert('fuel_entries', entry.toMap());
  }

  Future<List<FuelEntry>> getFuelEntries({int? vehicleId}) async {
    final db = await database;

    final rows = await db.query(
      'fuel_entries',
      where: vehicleId == null ? null : 'vehicle_id = ?',
      whereArgs: vehicleId == null ? null : [vehicleId],
      orderBy: 'entry_date DESC, id DESC',
    );

    return rows.map(FuelEntry.fromMap).toList();
  }

  Future<FuelEntry?> getFuelEntryById(int id) async {
    final db = await database;

    final rows = await db.query(
      'fuel_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return FuelEntry.fromMap(rows.first);
  }

  Future<int> updateFuelEntry(FuelEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Fuel entry ID is required for update');
    }

    _validateFuelEntry(entry);
    final db = await database;

    return db.update(
      'fuel_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteFuelEntry(int id) async {
    final db = await database;

    return db.delete(
      'fuel_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
      Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
   
