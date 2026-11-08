import '../models/distance_entry.dart';
import 'app_database.dart';

class DistanceRepository {
  DistanceRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createDistanceEntry(DistanceEntry entry) async {
    // Validate entry
    final error = entry.validate();
    if (error != null) throw ArgumentError(error);
    final db = await _database.database;
    return db.insert('distance_entries', entry.toMap());
  }

  Future<List<DistanceEntry>> getDistanceEntries({int? vehicleId}) async {
    final db = await _database.database;
    final rows = await db.query(
      'distance_entries',
      where: vehicleId == null ? null : 'vehicle_id = ?',
      whereArgs: vehicleId == null ? null : [vehicleId],
      orderBy: 'recorded_at DESC, id DESC',
    );
    return rows.map(DistanceEntry.fromMap).toList();
  }

  Future<DistanceEntry?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query('distance_entries', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return DistanceEntry.fromMap(rows.first);
  }

  Future<int> updateDistanceEntry(DistanceEntry entry) async {
    if (entry.id == null) throw ArgumentError('ID required for update');
    final error = entry.validate();
    if (error != null) throw ArgumentError(error);
    final db = await _database.database;
    return db.update('distance_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteDistanceEntry(int id) async {
    final db = await _database.database;
    return db.delete('distance_entries', where: 'id = ?', whereArgs: [id]);
  }
}

