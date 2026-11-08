import '../models/gps_ride.dart';
import 'app_database.dart';

class GpsRideRepository {
  GpsRideRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createGpsRide(GpsRide ride) async {
    final error = ride.validate();
    if (error != null) throw ArgumentError(error);
    final db = await _database.database;
    return db.insert('gps_rides', ride.toMap());
  }

  Future<List<GpsRide>> getGpsRides({int? vehicleId}) async {
    final db = await _database.database;
    final rows = await db.query(
      'gps_rides',
      where: vehicleId == null ? null : 'vehicle_id = ?',
      whereArgs: vehicleId == null ? null : [vehicleId],
      orderBy: 'start_time DESC, id DESC',
    );
    return rows.map(GpsRide.fromMap).toList();
  }

  Future<GpsRide?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query('gps_rides', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return GpsRide.fromMap(rows.first);
  }

  Future<int> updateGpsRide(GpsRide ride) async {
    if (ride.id == null) throw ArgumentError('ID required for update');
    final error = ride.validate();
    if (error != null) throw ArgumentError(error);
    final db = await _database.database;
    return db.update('gps_rides', ride.toMap(), where: 'id = ?', whereArgs: [ride.id]);
  }

  Future<int> deleteGpsRide(int id) async {
    final db = await _database.database;
    return db.delete('gps_rides', where: 'id = ?', whereArgs: [id]);
  }
}

