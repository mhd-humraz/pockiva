
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pockiva/data/app_database.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pockiva_db_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('Fresh database creates all six tables', () async {
    final dbPath = '${tempDir.path}/fresh.db';
    final appDb = AppDatabase.forTesting(dbPath);

    try {
      final db = await appDb.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );

      final tableNames = tables.map((row) => row['name']).toSet();

      expect(
        tableNames,
        containsAll([
          'goals',
          'entries',
          'vehicles',
          'fuel_entries',
          'distance_entries',
          'gps_rides',
        ]),
      );
    } finally {
      await appDb.close();
    }
  });

  test(
    'Version 3 database upgrades to version 5 without losing data',
    () async {
      final dbPath = '${tempDir.path}/migration.db';

      // Create a realistic version 3 database.
      final oldDb = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 3,
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
                FOREIGN KEY(goal_id) REFERENCES goals(id)
                  ON DELETE CASCADE
              )
            ''');

            await db.execute('''
              CREATE TABLE vehicles (
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
              CREATE TABLE fuel_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                vehicle_id INTEGER NOT NULL,
                amount_paise INTEGER NOT NULL,
                quantity_ml INTEGER NOT NULL,
                fuel_type TEXT NOT NULL,
                refill_type TEXT NOT NULL,
                entry_date TEXT NOT NULL,
                notes TEXT,
                created_at TEXT NOT NULL,
                FOREIGN KEY(vehicle_id) REFERENCES vehicles(id)
                  ON DELETE CASCADE
              )
            ''');
          },
        ),
      );

      try {
        // Insert existing savings data.
        final goalId = await oldDb.insert('goals', {
          'name': 'New Laptop',
          'target_paise': 5000000,
          'duration_days': 100,
          'start_date': '2026-01-01',
          'saving_mode': 'daily',
          'created_at': '2026-01-01T00:00:00.000',
        });

        await oldDb.insert('entries', {
          'goal_id': goalId,
          'day_number': 1,
          'entry_date': '2026-01-01',
          'amount_paise': 50000,
          'note': 'First saving',
        });

        // Insert an existing vehicle.
        await oldDb.insert('vehicles', {
          'name': 'Passion Pro',
          'category': 'motorcycle',
          'manufacturer': 'Hero',
          'model': 'Passion Pro',
          'fuel_type': 'petrol',
          'nickname': null,
          'notes': null,
          'created_at': '2026-01-01T00:00:00.000',
          'updated_at': '2026-01-01T00:00:00.000',
        });
      } finally {
        await oldDb.close();
      }

      // Opening at version 5 triggers the actual migration.
      final appDb = AppDatabase.forTesting(dbPath);

      try {
        final db = await appDb.database;

        expect(await db.getVersion(), 5);

        final goals = await db.query('goals');
        final entries = await db.query('entries');
        final vehicles = await db.query('vehicles');

        expect(goals.length, 1);
        expect(goals.first['name'], 'New Laptop');

        expect(entries.length, 1);
        expect(entries.first['amount_paise'], 50000);

        expect(vehicles.length, 1);
        expect(vehicles.first['name'], 'Passion Pro');

        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        );

        final tableNames = tables.map((row) => row['name']).toSet();

        expect(tableNames, contains('distance_entries'));
        expect(tableNames, contains('gps_rides'));
      } finally {
        await appDb.close();
      }
    },
  );
  
  test('Foreign keys prevent orphan records and cascade vehicle deletion',
      () async {
    final dbPath = '${tempDir.path}/foreign_keys.db';
    final appDb = AppDatabase.forTesting(dbPath);

    try {
      final db = await appDb.database;

      // Verify foreign keys are enabled.
      final fkResult = await db.rawQuery('PRAGMA foreign_keys');
      expect(fkResult.first['foreign_keys'], 1);

      // Create a vehicle.
      final now = DateTime.now().toIso8601String();

      final vehicleId = await db.insert('vehicles', {
        'name': 'Test Bike',
        'category': 'motorcycle',
        'manufacturer': 'Hero',
        'model': 'Test Model',
        'fuel_type': 'petrol',
        'created_at': now,
        'updated_at': now,
      });

      // Insert related records.
      await db.insert('fuel_entries', {
        'vehicle_id': vehicleId,
        'amount_paise': 10000,
        'quantity_ml': 1000,
        'fuel_type': 'petrol',
        'refill_type': 'partial',
        'entry_date': now,
        'created_at': now,
      });

      await db.insert('distance_entries', {
        'vehicle_id': vehicleId,
        'distance_m': 5000,
        'journey_id': 'test-journey-1',
        'recorded_at': now,
        'created_at': now,
      });

      await db.insert('gps_rides', {
        'vehicle_id': vehicleId,
        'distance_m': 10000,
        'duration_s': 1200,
        'journey_id': 'test-journey-2',
        'start_time': now,
        'end_time': now,
        'created_at': now,
      });

      // Verify related records exist.
      expect(await db.query('fuel_entries'), hasLength(1));
      expect(await db.query('distance_entries'), hasLength(1));
      expect(await db.query('gps_rides'), hasLength(1));

      // Deleting the vehicle should cascade to its related records.
      await db.delete(
        'vehicles',
        where: 'id = ?',
        whereArgs: [vehicleId],
      );

      expect(await db.query('vehicles'), isEmpty);
      expect(await db.query('fuel_entries'), isEmpty);
      expect(await db.query('distance_entries'), isEmpty);
      expect(await db.query('gps_rides'), isEmpty);

      // A child record with a nonexistent vehicle must be rejected.
      expect(
        () => db.insert('fuel_entries', {
          'vehicle_id': 999999,
          'amount_paise': 10000,
          'quantity_ml': 1000,
          'fuel_type': 'petrol',
          'refill_type': 'partial',
          'entry_date': now,
          'created_at': now,
        }),
        throwsA(isA<Exception>()),
      );
    } finally {
      await appDb.close();
    }
  });

}
